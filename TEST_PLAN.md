# Al-Khair — Test Plan (Phase-Zero Plan)

> **Status:** Planning document. Maps required tests to each implementation phase (Section 3 of
> the kickoff). Tests trace to FRs/NFRs and to the data dictionary. The **Rules Unit Testing gate
> at Phase 2** must pass before any screen is built.

## Tooling

- **Unit / widget:** `flutter_test`, `mocktail` (mocks), `riverpod`'s `ProviderContainer` overrides.
- **Rules:** `@firebase/rules-unit-testing` against the **Firebase Emulator Suite**.
- **Cloud Functions:** `firebase-functions-test` + emulator.
- **Integration (E2E):** `integration_test` package driving the app against the emulator.
- **Coverage:** `flutter test --coverage`; target ≥80% on domain + data layers.

Every phase ends with `flutter analyze` clean and the phase's tests green before proceeding.

---

## Phase 1 — Core setup
**Scope:** scaffolding, theme, visual identity, logo assets, dev/prod flavors, App Check.

| Type | Tests |
|---|---|
| Unit | Theme tokens resolve to the exact palette (`#16294F`, `#C89A4E`, `#3E8E5C`, …); Cairo text theme weights; enum ↔ snake_case mappers for all 7 collections (round-trip). |
| Widget | Splash/branding renders; app defaults to **RTL** Arabic locale (NFR4). |
| Config | `FLAVOR=dev/prod` selects the correct `firebase_options`; App Check initializes (debug provider in dev). |

**Run:** on every commit. **Gate:** `flutter analyze` clean, app boots to branded splash.

---

## Phase 2 — Authentication + Authorization  ⟵ **security gate**
**Scope:** Phone Auth/OTP, `Users` (+ volunteer `Volunteers`) creation, Custom Claims function,
route guards, and **`firestore.rules` proven via Rules Unit Testing FIRST**.

**2a. Rules Unit Tests (must pass before any screen work) — covers `firestore.rules` §2.2 of SECURITY.md:**
- `Users`: self-create only; `role` immutable; `password_hash` write rejected; delete forbidden.
- `Volunteers`: self-create forces `approval_status="pending"`; owner may update location only;
  only same-charity `charity_admin` flips `approval_status`; others rejected.
- `CharityAdmins`: all client writes rejected.
- `DonationReports`: donor creates own report only, `safety_confirmed==true` required, `quantity>0`,
  lat/lng in range, `status=="reported"`; unapproved volunteer cannot claim; approved volunteer
  claims only an unassigned report and sets `volunteer_id==uid`; only assigned volunteer advances
  `assigned→collected→delivered`; illegal jumps/reversals rejected; `created_at`/`donor_id`/PK
  immutable; delete forbidden.
- `Notifications`: client create rejected; recipient may update only `is_read`.
- `Reports`: all client writes rejected; read only by same-charity admin.

**2b. Function tests:** `onUsersWrite` sets the correct claim per `role`; approval change mirrors
into claims + writes the `claims_updated_at` refresh marker.

**2c. Widget/unit:** OTP state machine (request→sent→verify→success/expire/resend/lock); donor vs
volunteer post-OTP branch creates the right docs; route guards block cross-role access
(donor cannot reach volunteer/admin routes and vice versa).

**Run:** 2a runs and passes **before** 2c. **Gate:** rule tests green; real login/logout per role;
role isolation proven.

---

## Phase 3 — Donor module (Screens 2, 3)
**Scope:** report submission (FR2/3/4) with **rate limiting** + **double validation**; status/
notifications (FR5).

| Type | Tests |
|---|---|
| Unit | Client validators (quantity>0, mandatory safety checkbox, readiness time); GPS capture (FR3) maps to `latitude/longitude`; report DTO ↔ `DonationReports` mapping. |
| Widget | Report screen blocks submit until `safety_confirmed`; status tracker maps enum → Arabic labels (`reported/assigned/collected/delivered/expired`); notifications feed renders reverse-chronological. |
| Function/Rules | Report-creation rate-limit counter (transaction) rejects on breach with `RATE_LIMIT_EXCEEDED`; server re-validates quantity/lat/lng even if client bypassed. |

---

## Phase 4 — Volunteer module (Screens 4, 5)
**Scope:** proximity alert (FR6), accept/decline (FR7), navigation (FR8), pickup/delivery (FR9).

| Type | Tests |
|---|---|
| Unit | Proximity Cloud Function selects volunteers within `DEFAULT_DISPATCH_RADIUS_KM` using `current_lat/lng`; distance calc; reassignment after N failed attempts (Activity Diagram Fig 4.5). |
| Widget | Alert card fields (category, quantity, distance, time-since); accept sets `assigned` + `volunteer_id`; the two confirm buttons advance status in sequence. |
| Rules | Only approved + assigned volunteer can advance; decline leaves report open. |

---

## Phase 5 — Charity Admin module (Screens 6, 7)
**Scope:** dashboard (FR11), volunteer approval (FR10).

| Type | Tests |
|---|---|
| Unit | Dashboard aggregations scoped by `charity_id`; status-badge color mapping. |
| Widget | Approval screen lists pending volunteers (vehicle_type, phone); approve → `approval_status=approved`; responsive layout renders on web breakpoint. |
| Rules | Admin acts only within own `charity_id`. |

---

## Phase 6 — Reporting & export (Screens 8–12)
**Scope:** report generation + export (FR12).

| Type | Tests |
|---|---|
| Unit | Report aggregation Function computes `total_donations`/`total_quantity` correctly for a period; category breakdown percentages; volunteer-performance ranking + leader badge. |
| Widget | Reports directory (last-refreshed), monthly pie chart, category sortable table, PDF preview renders header (mark, charity, date) + category table (Fig 5.12). |
| Rules | `Reports` writes rejected from client; reads scoped to admin's charity. |

---

## Phase 7 — Full coverage & final verification
**Scope:** fill remaining unit/widget gaps; **E2E donation journey**; final security review.

- **Integration test (Figure 4.8, full journey):** donor reports (with safety confirmation) →
  Function dispatches → volunteer receives alert → accepts (`assigned`) → navigates → confirms
  collection (`collected`) → confirms delivery (`delivered`) → donor status + admin dashboard
  reflect the completed record (FR13). Run against the emulator.
- **Final rules review:** re-run the full Phase-2 rules suite plus new negative cases discovered
  during Phases 3–6; confirm no regression.
- **Coverage report:** `flutter test --coverage`; confirm domain/data ≥80%.

**Gate:** all suites green; E2E journey passes; security review sign-off.
