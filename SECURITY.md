# Al-Khair — Security Design (Phase-Zero Plan)

> **Status:** Planning document, written **before** any implementation. This is the highest-value
> artifact of Phase Zero. Every rule and field traces to Chapter Four's data dictionary
> (Tables 4.2–4.8) or a functional requirement. `firestore.rules` is validated with Firebase
> Rules Unit Testing **before any screen is built** (gates Phase 2).

Backing NFR: **NFR1** — signed tokens, role-based access control, HTTPS in transit.

---

## 1. Authentication — username + password, with Phone OTP as sign-up/reset verification (FR1)

> **Supersedes the original "unified Phone Auth + OTP as the login mechanism" design** — changed
> per supervisor direction; see ARCHITECTURE.md §6 item 15 for the full rationale and the
> data-dictionary reinterpretations this required. This section describes the **current** model.

### 1.1 Login vs. verification are separate concerns

**Login** is username + password (Firebase Email/Password auth under the hood — see 1.4 for the
synthetic-email mapping). **Phone OTP is not the login mechanism.** It appears in exactly two
places: as a mandatory **sign-up verification gate** (1.2) and as the verification step for
**forgot-password** (1.3). No OTP is involved in ordinary login.

`Users.password_hash` (Table 4.2) is still **never written by the app**: the password lives in
Firebase Auth, not Firestore — `firestore.rules` continues to forbid the field on the `Users` doc.

Charity administrators remain **provisioned out-of-band** by the platform owner (Ch.5 §5.2.1 —
the `CharityAdmins` record has no public creation path) and are excluded from the self-signup
form entirely; `firestore.rules`' `Users` create rule only allows `role in ['donor','volunteer']`.

### 1.2 Sign-up (OTP as a verification gate, not the login method)

```
SignUpForm(username, password, name, phone, role[donor|volunteer], + role-specific fields)
  submit → hold form in memory ONLY (no Firebase Auth account, no Firestore doc yet)
         → requestOtp(phone)  [existing OTP send/verify/resend/cooldown mechanism, unmodified]
OTP verify success:
  → linkWithCredential(EmailAuthProvider({username}@alkhair-app.internal, password))
      onto the OTP-verified phone-auth user (Firebase OTP inherently signs in a phone-auth
      account; linking avoids a second, orphaned account)
      ├─ email-already-in-use → "username already taken" (surfaced ONLY here, after OTP, never
      │    before — Firebase's own uniqueness check, no separate manual Firestore check)
      └─ success →
  → create Users/{uid} = { name, phone, username, phone_verified: true, role, created_at }
    (phone_verified: true is baked in from creation — there is no unverified-account state)
  → VOLUNTEER only: update Users/{uid} = { email }; create Volunteers/{uid} = {
      user_id, charity_id, approval_status: "pending", vehicle_type,
      current_lat: null, current_lng: null }
OTP fails / expires / abandoned:
  → no Firebase Auth account, no Firestore doc exist. User simply restarts sign-up.
    No pending-account cleanup logic exists or is needed.
```

The OTP state machine itself (send/verify/resend-with-cooldown/lock-after-N-attempts) is
unchanged from the original design — see the state diagram this section used to carry; it now
gates account *creation* rather than *login*.

### 1.3 Forgot password (reuses the phone already on file)

```
ForgotPasswordForm(username only — phone is never re-entered)
  submit → lookupPhoneForUsername(username)   [new callable, Admin SDK — Firestore rules only
             let a client read its own Users doc, so this can't be a direct client query]
  found  → requestOtp(phone)  [same OTP screen component, flowMode=passwordReset]
             OTP verify success → signs back into the SAME uid (phone was linked to it at
             sign-up) → updatePassword(newPassword)  [reset, not linkWithCredential — no new
             account]
  not found → generic "if this account exists, a code was sent" message; no OTP sent, no
             navigation (avoids confirming/denying account existence in the UI)
```

While a reset is in flight, `passwordResetInProgress` overrides the router's normal
role-derived stage — otherwise an *existing* user's OTP re-auth would redirect them straight to
their home screen (their `Users` doc already exists) before they ever set a new password.

### 1.4 Username → synthetic email mapping

Firebase Auth has no native username provider. `{username}@alkhair-app.internal` is used
internally for Email/Password sign-up/sign-in and is **never shown in the UI**.

### 1.5 First successful login — document creation (superseded)

The account-type-selector-after-login flow this subsection used to describe (`onLoginSuccess`
branching into donor/volunteer registration) is superseded by 1.2 above: role and all
registration fields are now collected **before** OTP, in the sign-up form itself, and the
`Users`/`Volunteers` docs are created at OTP success rather than after a bare-phone login.
`CharityAdmins` docs still only come from the out-of-band provisioning path, never from any
client flow.

---

## 2. Authorization — two layers

### 2.1 Layer 1 — Custom Claims via Cloud Function

- A Cloud Function **`onUsersWrite`** triggers on create/update of `Users/{uid}`. It reads
  `role` and sets a matching **custom claim** (`role: donor|volunteer|charity_admin`) on the Auth
  user. For volunteers it additionally mirrors `approval_status` and `charity_id` (read from
  `Volunteers/{uid}`) into claims so rules and the client can gate without extra reads.
- **Forced token refresh after a claims change:** the function writes a
  `Users/{uid}.claims_updated_at` marker; the client listens and calls
  `FirebaseAuth.currentUser.getIdToken(true)` to force-refresh, so a newly-approved volunteer or a
  revoked account picks up the change without re-login. Rules never trust a claim older than the
  marker for privileged transitions.
- Claims are the **fast path** for routing/guards; Firestore Rules are the **authoritative**
  enforcement (defence in depth).

### 2.2 Layer 2 — `firestore.rules`

The full draft is in `firestore.rules`. Mapping of each rule group to the data-dictionary
relationship it protects:

| Collection | Rule intent | Protects (data dictionary) |
|---|---|---|
| `Users` | A user reads/writes only their own doc; `role` is set once at create and is immutable thereafter; `password_hash` write is forbidden. | Table 4.2 — identity & role integrity (NFR1 RBAC) |
| `Volunteers` | Owner may create their sub-doc with `approval_status="pending"` only; **only** a `charity_admin` of the same `charity_id` may change `approval_status`; `current_lat/lng` writable only by the owning volunteer. | Table 4.3 — approval is admin-controlled (FR10); location integrity (FR6) |
| `CharityAdmins` | No client create/update/delete; readable by the admin themselves. | Table 4.4 — out-of-band provisioning only |
| `Charities` | Read for authenticated users; write admin-only. | Table 4.5 — reference data integrity |
| `DonationReports` | Donor creates their own report (`donor_id == uid`, `status=="reported"`, `safety_confirmed==true`, server `created_at`); an **approved** volunteer may claim an unassigned report (`status reported→assigned`, set `volunteer_id==uid`); only the **assigned** volunteer advances `assigned→collected→delivered`; `created_at`, `donor_id`, PK immutable; admins read within their `charity_id` scope. | Table 4.6 — the core transaction (FR2–FR9, FR13) |
| `Notifications` | Recipient (`user_id==uid`) reads and may set `is_read`; content is written only by Cloud Functions (server). | Table 4.7 — recipient privacy, server-authored content (FR5, FR6) |
| `Reports` | Read by admins of the same `charity_id`; **write server-only** (Cloud Function aggregation). | Table 4.8 — report integrity (FR12) |

State-transition legality (the `status` enum) is enforced in rules as an allowed-transition table
so a client can never jump, skip, or reverse states.

---

## 3. Rate limiting

**Operations that require limiting:**
1. **OTP requests** (per phone number / per App Check token) — abuse & cost control.
2. **`DonationReports` creation** (per donor) — spam/flood control.
3. **`Reports` generation** (per admin) — expensive aggregation.

**Mechanism (concurrency-safe):** a per-actor counter document
(`RateLimits/{scope}_{actorId}`) is incremented **inside a Firestore transaction** in the relevant
Cloud Function (report creation and report generation) so the cap holds under concurrent writes.
Each counter carries a window (`window_start`, `count`, `limit`); the transaction resets the window
when expired and rejects when `count >= limit`.

> **On `RateLimits` (approved technical exception, not an undocumented addition):** this is an
> **internal, server-managed technical collection used only by Cloud Functions** for rate-limit
> counters. It is **explicitly not one of the 7 domain collections** defined by the Chapter Four
> ERD / data dictionary (Users, Volunteers, CharityAdmins, Charities, DonationReports,
> Notifications, Reports) and carries no business data. It is an **approved infrastructure
> exception** confirmed with the project owner. Clients have **no access**: it is written only via
> the Admin SDK, and `firestore.rules` denies it through the default `match /{document=**}` rule
> (no explicit allow), so it never widens the client-facing data model.

- OTP: primarily Firebase's built-in per-number throttling + App Check; the app adds a client
  cooldown (60s) and surfaces backoff.
- Report creation / report generation: enforced in the Cloud Function via the transactional
  counter; the matching `firestore.rules` still validate shape so a direct client write can't
  bypass business limits (writes that must be limited route through the Function; rules forbid the
  client from writing server-only fields).

**On breach:** the Function throws `HttpsError('resource-exhausted', ...)` with a specific
**error code `RATE_LIMIT_EXCEEDED`**; the client maps it to a clear Arabic message
(e.g. «لقد تجاوزت الحد المسموح، يرجى المحاولة بعد قليل») via the error layer (§6). No internal
detail (counter, window, thresholds) is exposed to the user.

**Integration with App Check:** App Check is the **first line of defence** — it runs before any
rate-limit logic, rejecting requests from unattested clients so limits are only spent on
legitimate traffic (§5).

---

## 4. Double data validation (client + backend, no client-only trust)

Every sensitive field is validated on the client **and** re-validated by a backend authority
(Firestore Rules and/or Cloud Function). No field relies on client validation alone.

| Field (collection) | Client-side rule | Backend rule (Rules / Function) |
|---|---|---|
| `quantity` (DonationReports) | required, numeric, `> 0`, sane upper bound | Rules: `is number && quantity > 0 && quantity <= MAX` |
| `status` (DonationReports) | UI only offers legal next state | Rules: allowed-transition table; assigned-volunteer-only advance |
| `role` (Users) | chosen once at account-type step | Rules: set at create, immutable after; claim set by `onUsersWrite` |
| `latitude` / `longitude` (DonationReports) | from `geolocator`, ranges [-90,90]/[-180,180] | Rules: `is number` + range check; not client-editable after create |
| `safety_confirmed` (DonationReports) | mandatory checkbox, must be `true` to submit (FR4) | Rules: `create` requires `safety_confirmed == true` |
| `approval_status` (Volunteers) | client can only ever send `"pending"` at self-create | Rules: transition to approved/revoked only by same-charity `charity_admin` |
| `volunteer_id` (DonationReports) | set implicitly by accept action | Rules: only an approved volunteer, only when unassigned, `== request.auth.uid` |
| `email` (Users, set at volunteer extra-step) | required + format at extra-step | Rules: owner-only `Users` update (existing rule); non-empty string |
| `created_at` (all) | not set by client | Rules: must equal `request.time` on create; immutable on update |
| `total_donations` / `total_quantity` (Reports) | never entered by user | Function-computed; Rules forbid client writes to `Reports` |

---

## 5. App Check — first line of defence

- **Enabled on Auth, Firestore, Cloud Functions, and Storage** from Phase 1.
- **Providers by build:** mobile → **Play Integrity** (Android) / **DeviceCheck** or App Attest
  (iOS); web (admin) → **reCAPTCHA Enterprise/v3**. A debug provider is used only in local dev.
- App Check tokens are required **before** Auth/OTP, before privileged Firestore reads/writes, and
  before callable Functions — so rate-limit budgets and OTP quotas are only spent on attested,
  legitimate clients. Enforcement is set to **hard-enforce** in prod (metrics-only during Phase-1
  rollout, then enforce before Phase 2 ships).

---

## 6. Secrets & environment

- **Two Firebase projects from day one:** `alkhair-dev` and `alkhair-prod`, each with its own
  `firebase_options.dart` generated by `flutterfire configure` and selected per build flavor.
  No dev data or keys ever ship to prod and vice versa.
- **Google Maps keys** are passed via `--dart-define` (or an untracked `env/*.json` consumed by
  `--dart-define-from-file`); **never committed**. Android/iOS platform keys are injected via
  build config, restricted by package name / bundle id + API.
- **Expected environment variables:**

| Variable | Purpose |
|---|---|
| `FLAVOR` | `dev` \| `prod` — selects Firebase options + endpoints |
| `MAPS_API_KEY_ANDROID` | Android Maps SDK key (restricted) |
| `MAPS_API_KEY_IOS` | iOS Maps SDK key (restricted) |
| `MAPS_API_KEY_WEB` | Web Maps JS key (referrer-restricted, admin build) |
| `DIRECTIONS_API_KEY` | Directions API (FR8 routing), server-proxied if possible |
| `APP_CHECK_DEBUG_TOKEN` | local dev only, never in prod |
| `DEFAULT_DISPATCH_RADIUS_KM` | configurable proximity radius (FR6) |
| `RECAPTCHA_SITE_KEY` | web App Check (admin build) |

`.gitignore` excludes `env/`, `*.keystore`, `google-services*.json` overrides, and any
`firebase_options*.dart` that carries prod identifiers if policy requires (dev committed, prod
injected).

### 6.1 Run modes — Emulator Suite (default) vs. real cloud

The single `lib/main.dart` entrypoint connects to the **local Firebase Emulator Suite by
default** (`kUseEmulator` in `lib/core/constants/app_constants.dart`, wired in
`lib/bootstrap.dart`). This is required on the iOS Simulator: real Phone Auth needs native
APNs/reCAPTCHA verification, which the Simulator cannot complete and which crashes natively
(`PhoneAuthProvider.swift` nil-unwrap) — the Auth emulator skips that verification entirely.
There is only one Firebase project now, `alkhair-bisha-dev` (see ARCHITECTURE.md §6 items
7–9) — no dev/prod flavor split, no `--dart-define=FLAVOR`.

- **Emulator (default), automated Jest suites** (`test:rules`/`test:functions` — self-contained,
  seed and query within one project per run):
  1. `PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH" firebase emulators:start --project=demo-alkhair`
     (build functions first: `npm --prefix functions run build`)
- **Emulator (default), manual/interactive app testing** (`flutter run`): **must** start the
  emulator suite with `--project=alkhair-bisha-dev`, matching `lib/firebase_options.dart`
  exactly — **not** `demo-alkhair`. Firestore document storage and callable-function HTTP
  routing are bucketed per requested project ID; a mismatch here silently makes app-written
  docs invisible under the wrong project ID and turns callable 404s into a generic
  `permission-denied` client-side (found the hard way during the Phase 7 manual E2E).
  1. `PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH" firebase emulators:start --project=alkhair-bisha-dev`
     (build functions first: `npm --prefix functions run build`)
  2. `flutter run -t lib/main.dart`
  3. Phone sign-in accepts any number; read the OTP code from the emulator Auth log/UI
     (`http://localhost:4000` by default).
- **Real cloud** (production consolidation testing / demo recording against `alkhair-bisha-dev`,
  role-isolation verification with production rules, real test phone numbers only — never a
  live number): `flutter run -t lib/main.dart --dart-define=USE_EMULATOR=false`.

Ports (from `firebase.json`): auth `9099`, firestore `8085` (non-default — `8080` is taken
locally), functions `5001`. Cloud Functions / Firestore now live in `europe-west1`, not the
originally-documented `me-central2` — see ARCHITECTURE.md §6 items 7–9 for why.

---

## 7. Logging & monitoring

- **Crashlytics** captures uncaught Flutter errors, zoned async errors, and manually-recorded
  non-fatals at repository/service boundaries. Cloud Functions log to Cloud Logging.
- **Unified error layer (Result/Either):** every repository returns `Either<Failure, T>` (`fpdart`).
  `Failure` is a `freezed` union: `AuthFailure`, `NetworkFailure`, `PermissionFailure`,
  `RateLimitFailure`, `ValidationFailure`, `UnknownFailure`. Services translate raw exceptions
  (`FirebaseAuthException`, `FirebaseException`, `HttpsError`) into a `Failure` at the boundary.
- **Arabic translation without leakage:** a single mapper turns each `Failure` into a safe,
  human Arabic message (e.g. permission-denied → «ليس لديك صلاحية لهذا الإجراء»; rate-limit →
  «لقد تجاوزت الحد المسموح…»). Internal codes/stack traces go to Crashlytics only, never to the UI.

---

## 8. Security-testing plan (gates Phase 2)

- `firestore.rules` is tested with the **Firebase Rules Unit Testing** library
  (`@firebase/rules-unit-testing`) against the **emulator**, covering **every** relationship in the
  §2.2 table:
  - donor can create only own report with `safety_confirmed==true`; cannot set `status` beyond
    `reported`; cannot write another donor's report.
  - unapproved volunteer cannot claim a report; approved volunteer can claim only an unassigned
    report and set `volunteer_id==uid`.
  - only the assigned volunteer advances `assigned→collected→delivered`; illegal jumps/reversals
    rejected.
  - only same-charity `charity_admin` flips `approval_status`; a donor/volunteer cannot.
  - `Reports` and `Notifications` reject all client writes of server-authored fields.
  - `created_at`, `role`, PKs proven immutable.
- **These tests must pass before any screen is built.** No screen is ever developed on top of
  untested rules (this is the Phase-2 gate in `TEST_PLAN.md`).
