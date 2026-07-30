# Charity Admin Provisioning

`charity_admin` accounts are **never** created through the app's sign-up form.
`firestore.rules`' `Users` create rule only permits `role in ['donor',
'volunteer']`, and `CharityAdmins` denies all client writes
(`allow create, update, delete: if false`) — see `ARCHITECTURE.md` §6 item 15
and `SECURITY.md`. This is intentional: it closes a self-escalation path where
a signed-up user could grant themselves admin access.

Instead, admins are provisioned out-of-band by the platform owner using
`functions/scripts/seed_admin.js`, a standalone Admin SDK script that bypasses
`firestore.rules` entirely (Admin SDK calls aren't subject to security rules).
It:

1. Creates the Firebase Auth user on the **email/password** provider, using
   the app's synthetic-email convention (`{username}@alkhair-app.internal`,
   see `lib/core/utils/username_email.dart`) so the account can sign in
   through the same `signInWithEmailAndPassword` flow as everyone else.
2. Sets the `role: 'charity_admin'` custom claim directly via
   `admin.auth().setCustomUserClaims` (routing depends on the claim, not just
   the Firestore `role` field).
3. Writes the `Users/{uid}` doc (`role: 'charity_admin'`, `username`, `name`).
4. Writes the `CharityAdmins/{uid}` doc linking the account to a
   `charity_id` from the `Charities` collection.

## Usage

### Against the local emulator

```
firebase emulators:start --only auth,firestore,functions --project demo-alkhair

FIRESTORE_EMULATOR_HOST=127.0.0.1:8085 FIREBASE_AUTH_EMULATOR_HOST=127.0.0.1:9099 \
  GCLOUD_PROJECT=demo-alkhair ADMIN_PASSWORD=<password> \
  node functions/scripts/seed_admin.js
```

### Against a real project

Requires Admin SDK credentials with access to the target project — either a
service account key (`GOOGLE_APPLICATION_CREDENTIALS=/path/key.json`) or your
own `gcloud auth application-default login` session:

```
GOOGLE_APPLICATION_CREDENTIALS=~/.config/gcloud/application_default_credentials.json \
  GCLOUD_PROJECT=alkhair-bisha-dev ADMIN_PASSWORD=<password> \
  node functions/scripts/seed_admin.js
```

### Env vars

| Var | Required | Default | Meaning |
|---|---|---|---|
| `ADMIN_PASSWORD` | yes | — | Password for the new Auth account. No insecure default — the script errors without it. |
| `ADMIN_USERNAME` | no | `admin_albirr_bisha` | Login username (mapped to `{username}@alkhair-app.internal`). |
| `ADMIN_UID` | no | `admin-albirr-bisha` | Firestore doc id / Auth uid. |
| `ADMIN_NAME` | no | `مشرف جمعية البر بمحافظة بيشة` | Display name written to `Users.name`. |
| `ADMIN_PHONE` | no | (omitted) | Optional profile field only — no longer the sign-in identifier. |
| `CHARITY_ID` | no | `albirr-bisha` | Must reference an existing `Charities` doc (see `seed_charities.js`). |
| `GCLOUD_PROJECT` | no | `demo-alkhair` | Target project id. |

The script is idempotent on the Auth user (`auth/uid-already-exists` is
swallowed) and overwrites the `Users`/`CharityAdmins` docs on rerun.

## Handling the password

Pick a strong, unique password per admin and hand it to them out of band (a
call, a password manager share, etc.) — never commit it to the repo or paste
it into an issue/PR. This script is for provisioning test/real admin accounts
one at a time before production launch; there is no self-service password
reset for `charity_admin` yet (see `ARCHITECTURE.md` line ~567 — resets are
manual via Firebase Console / this script until a proper admin tool exists).
