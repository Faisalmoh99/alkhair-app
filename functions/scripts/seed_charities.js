/**
 * Seeds the Charities collection (Table 4.5) with the real charity shown in the
 * approved Figure 5.6, «جمعية البر بمحافظة بيشة». Needed so the volunteer
 * registration dropdown is populated (Charities is server/owner-written; clients
 * cannot create it — firestore.rules).
 *
 * Against the emulator:
 *   FIRESTORE_EMULATOR_HOST=127.0.0.1:8085 GCLOUD_PROJECT=demo-alkhair \
 *     node functions/scripts/seed_charities.js
 *
 * Against a real project (Track B, needs credentials):
 *   GOOGLE_APPLICATION_CREDENTIALS=/path/key.json GCLOUD_PROJECT=alkhair-dev \
 *     node functions/scripts/seed_charities.js
 */
const admin = require('firebase-admin');

admin.initializeApp({ projectId: process.env.GCLOUD_PROJECT || 'demo-alkhair' });

async function main() {
  const id = 'albirr-bisha';
  await admin.firestore().collection('Charities').doc(id).set({
    charity_id: id,
    name: 'جمعية البر بمحافظة بيشة',
    registration_number: '',
    address: 'بيشة',
  });
  // eslint-disable-next-line no-console
  console.log(`Seeded Charities/${id}`);
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    // eslint-disable-next-line no-console
    console.error(err);
    process.exit(1);
  });
