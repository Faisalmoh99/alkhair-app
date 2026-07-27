/**
 * Cloud Function tests — onDonationReportCreated dispatch trigger (Phase 4, FR6).
 *
 * Emulator-based: seeds Volunteers docs directly via the Admin SDK (bypassing
 * rules, mirroring on_users_write.spec.ts), creates a DonationReports doc, and
 * polls for the Notifications docs the trigger writes. Asserts only approved
 * volunteers with a known location inside DISPATCH_RADIUS_KM are notified.
 *
 * Each test uses its own latitude "zone" (~1100+ km apart) so volunteers
 * seeded by one test can never be mistaken as nearby for another test's
 * report — the tests share one emulator instance and do not reset state
 * between them.
 *
 * Run: npm --prefix functions run build && \
 *   firebase emulators:exec --only auth,firestore,functions --project=demo-alkhair \
 *     "npm --prefix functions run test:functions"
 */
import * as admin from 'firebase-admin';

const PROJECT_ID = 'demo-alkhair';

beforeAll(() => {
  if (admin.apps.length === 0) {
    admin.initializeApp({ projectId: PROJECT_ID });
  }
});

const LNG = 42.5;
// ~0.01 deg latitude ≈ 1.1 km — comfortably inside the 10 km radius.
const INSIDE_OFFSET = 0.01;
// ~0.3 deg latitude ≈ 33 km — comfortably outside the 10 km radius.
const OUTSIDE_OFFSET = 0.3;

async function seedVolunteer(
  uid: string,
  overrides: Partial<{
    approval_status: string;
    current_lat: number | null;
    current_lng: number | null;
  }>,
) {
  await admin.firestore().doc(`Volunteers/${uid}`).set({
    user_id: uid,
    charity_id: 'charityA',
    approval_status: 'approved',
    vehicle_type: 'car',
    current_lat: null,
    current_lng: null,
    ...overrides,
  });
}

async function createReport(reportId: string, lat: number, lng: number) {
  await admin.firestore().doc(`DonationReports/${reportId}`).set({
    report_id: reportId,
    donor_id: 'dispatchDonor',
    volunteer_id: null,
    food_category: 'main_meals',
    quantity: 5,
    readiness_time: admin.firestore.Timestamp.fromMillis(Date.now() + 3600_000),
    latitude: lat,
    longitude: lng,
    safety_confirmed: true,
    status: 'reported',
    created_at: admin.firestore.FieldValue.serverTimestamp(),
  });
}

async function waitForNotificationCount(
  reportId: string,
  expected: number,
  timeoutMs = 15000,
): Promise<FirebaseFirestore.QueryDocumentSnapshot[]> {
  const start = Date.now();
  while (Date.now() - start < timeoutMs) {
    const snap = await admin
      .firestore()
      .collection('Notifications')
      .where('report_id', '==', reportId)
      .get();
    if (snap.docs.length >= expected) {
      return snap.docs;
    }
    await new Promise((r) => setTimeout(r, 300));
  }
  throw new Error(`Notifications for ${reportId} did not reach ${expected} within ${timeoutMs}ms`);
}

test('dispatches only to approved, in-radius volunteers with a known location', async () => {
  const zoneLat = 20.0;
  await seedVolunteer('dvNear', { current_lat: zoneLat + INSIDE_OFFSET, current_lng: LNG });
  await seedVolunteer('dvFar', { current_lat: zoneLat + OUTSIDE_OFFSET, current_lng: LNG });
  await seedVolunteer('dvUnapproved', {
    approval_status: 'pending',
    current_lat: zoneLat + INSIDE_OFFSET,
    current_lng: LNG,
  });
  await seedVolunteer('dvNoLocation', { current_lat: null, current_lng: null });

  const reportId = 'dispatchReport1';
  await createReport(reportId, zoneLat, LNG);

  // Wait for the one expected notification, then give the trigger a further
  // beat to prove no extra (unwanted) notifications land afterwards.
  await waitForNotificationCount(reportId, 1);
  await new Promise((r) => setTimeout(r, 2000));
  const finalSnap = await admin
    .firestore()
    .collection('Notifications')
    .where('report_id', '==', reportId)
    .get();

  expect(finalSnap.docs).toHaveLength(1);
  const notification = finalSnap.docs[0].data();
  expect(notification.user_id).toBe('dvNear');
  expect(notification.type).toBe('new_donation_alert');
  expect(notification.is_read).toBe(false);
  expect(notification.report_id).toBe(reportId);
  expect(notification.created_at).toBeTruthy();
});

test('notifies every approved in-radius volunteer, not just the nearest', async () => {
  const zoneLat = 30.0;
  await seedVolunteer('dvNear2', { current_lat: zoneLat + INSIDE_OFFSET, current_lng: LNG });
  await seedVolunteer('dvNear3', { current_lat: zoneLat, current_lng: LNG + INSIDE_OFFSET });

  const reportId = 'dispatchReport2';
  await createReport(reportId, zoneLat, LNG);

  const docs = await waitForNotificationCount(reportId, 2);
  const recipients = docs.map((d) => d.get('user_id')).sort();
  expect(recipients).toEqual(['dvNear2', 'dvNear3']);
});

test('no nearby volunteers means no Notifications are written', async () => {
  const zoneLat = 40.0;
  const reportId = 'dispatchReport3';
  await createReport(reportId, zoneLat, LNG);

  // Nothing to wait-for-success on; assert the negative after a settle beat.
  await new Promise((r) => setTimeout(r, 3000));
  const snap = await admin
    .firestore()
    .collection('Notifications')
    .where('report_id', '==', reportId)
    .get();
  expect(snap.docs).toHaveLength(0);
});
