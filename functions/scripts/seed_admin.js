/**
 * Provisions a charity_admin for local emulator testing (Ch.5 §5.2.1 —
 * CharityAdmins is provisioned out-of-band by the platform owner; there is no
 * public/client creation path). This script plays that platform-owner role:
 * it creates the Auth user on the email/password provider (using the same
 * synthetic-email convention as the app's username/password auth — see
 * lib/core/utils/username_email.dart), sets the `role` custom claim directly
 * (rather than relying on the onUsersWrite trigger, so it works even with
 * only the Firestore emulator running), and writes the Users + CharityAdmins
 * docs.
 *
 * Against the emulator:
 *   FIRESTORE_EMULATOR_HOST=127.0.0.1:8085 FIREBASE_AUTH_EMULATOR_HOST=127.0.0.1:9099 \
 *     GCLOUD_PROJECT=demo-alkhair ADMIN_PASSWORD=<password> \
 *     node functions/scripts/seed_admin.js
 *
 * Required env: ADMIN_PASSWORD.
 * Optional env overrides: ADMIN_UID, ADMIN_NAME, ADMIN_USERNAME, ADMIN_PHONE,
 * CHARITY_ID (defaults match the seeded charity in seed_charities.js).
 *
 * Against a real project (Track B, needs credentials):
 *   GOOGLE_APPLICATION_CREDENTIALS=/path/key.json GCLOUD_PROJECT=alkhair-dev \
 *     ADMIN_PASSWORD=<password> node functions/scripts/seed_admin.js
 */
const admin = require('firebase-admin');

const SYNTHETIC_EMAIL_DOMAIN = '@alkhair-app.internal';

admin.initializeApp({ projectId: process.env.GCLOUD_PROJECT || 'demo-alkhair' });

async function main() {
  const uid = process.env.ADMIN_UID || 'admin-albirr-bisha';
  const name = process.env.ADMIN_NAME || 'مشرف جمعية البر بمحافظة بيشة';
  const username = process.env.ADMIN_USERNAME || 'admin_albirr_bisha';
  const password = process.env.ADMIN_PASSWORD;
  const phone = process.env.ADMIN_PHONE;
  const charityId = process.env.CHARITY_ID || 'albirr-bisha';
  const email = `${username}${SYNTHETIC_EMAIL_DOMAIN}`;

  if (!password) {
    throw new Error('ADMIN_PASSWORD env var is required (no insecure default).');
  }

  try {
    await admin.auth().createUser({ uid, email, password, emailVerified: true });
  } catch (err) {
    if (err.code !== 'auth/uid-already-exists') {
      throw err;
    }
  }
  await admin.auth().setCustomUserClaims(uid, { role: 'charity_admin' });

  await admin.firestore().collection('Users').doc(uid).set({
    user_id: uid,
    name,
    username,
    ...(phone ? { phone } : {}),
    role: 'charity_admin',
    created_at: admin.firestore.FieldValue.serverTimestamp(),
  });
  await admin.firestore().collection('CharityAdmins').doc(uid).set({
    user_id: uid,
    charity_id: charityId,
  });

  // eslint-disable-next-line no-console
  console.log(`Seeded charity_admin ${uid} (username=${username}, charity_id=${charityId})`);
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    // eslint-disable-next-line no-console
    console.error(err);
    process.exit(1);
  });
