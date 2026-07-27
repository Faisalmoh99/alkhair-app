/**
 * Cloud Function tests — generateReport callable (Phase 6, FR12).
 *
 * Emulator-based via the client SDK (mirrors the Flutter app's export
 * action): asserts the happy-path aggregation (delivered-only, period
 * window), the persisted Reports doc shape, and that a non-admin is
 * rejected (TEST_PLAN.md Phase 6 Unit/Function tests).
 *
 * Run: npm --prefix functions run build && \
 *   firebase emulators:exec --only auth,firestore,functions --project=demo-alkhair \
 *     "npm --prefix functions run test:functions"
 */
import { initializeApp } from 'firebase/app';
import { connectAuthEmulator, getAuth, signInWithCustomToken } from 'firebase/auth';
import { connectFunctionsEmulator, getFunctions, httpsCallable } from 'firebase/functions';
import * as admin from 'firebase-admin';
import { Timestamp } from 'firebase-admin/firestore';
import { REGION } from '../src/region';

const PROJECT_ID = 'demo-alkhair';
const CHARITY_A = 'charityA';

beforeAll(() => {
  if (admin.apps.length === 0) {
    admin.initializeApp({ projectId: PROJECT_ID });
  }
});

let clientCounter = 0;

async function functionsFor(uid: string, claims: Record<string, unknown>) {
  const token = await admin.auth().createCustomToken(uid, claims);

  const app = initializeApp(
    { projectId: PROJECT_ID, apiKey: 'fake-api-key' },
    `test-${PROJECT_ID}-${clientCounter++}`,
  );
  const auth = getAuth(app);
  connectAuthEmulator(auth, 'http://127.0.0.1:9099', { disableWarnings: true });
  await signInWithCustomToken(auth, token);

  const functions = getFunctions(app, REGION);
  connectFunctionsEmulator(functions, '127.0.0.1', 5001);
  return functions;
}

async function seedAdmin(uid: string, charityId = CHARITY_A) {
  await admin.firestore().doc(`CharityAdmins/${uid}`).set({
    user_id: uid,
    charity_id: charityId,
  });
}

async function seedDonation(
  id: string,
  overrides: { status: string; quantity: number; created_at: Date },
) {
  await admin
    .firestore()
    .doc(`DonationReports/${id}`)
    .set({
      report_id: id,
      donor_id: 'donor1',
      volunteer_id: null,
      food_category: 'main_meals',
      quantity: overrides.quantity,
      readiness_time: Timestamp.fromDate(overrides.created_at),
      latitude: 20,
      longitude: 42,
      safety_confirmed: true,
      status: overrides.status,
      created_at: Timestamp.fromDate(overrides.created_at),
    });
}

test('aggregates only delivered reports within the period window', async () => {
  const adminUid = 'reportAdmin1';
  await seedAdmin(adminUid);

  const inWindow = new Date('2030-06-10T00:00:00Z');
  const outOfWindow = new Date('2030-07-01T00:00:00Z');

  await seedDonation('rep-delivered-1', {
    status: 'delivered',
    quantity: 10,
    created_at: inWindow,
  });
  await seedDonation('rep-delivered-2', {
    status: 'delivered',
    quantity: 5,
    created_at: inWindow,
  });
  await seedDonation('rep-reported', {
    status: 'reported',
    quantity: 999,
    created_at: inWindow,
  });
  await seedDonation('rep-out-of-window', {
    status: 'delivered',
    quantity: 999,
    created_at: outOfWindow,
  });

  const functions = await functionsFor(adminUid, { role: 'charity_admin' });
  const call = httpsCallable(functions, 'generateReport');

  const periodStart = new Date('2030-06-01T00:00:00Z').getTime();
  const periodEnd = new Date('2030-07-01T00:00:00Z').getTime();

  const result = await call({
    report_type: 'categoryDetail',
    period_start: periodStart,
    period_end: periodEnd,
  });

  const data = result.data as {
    report_id: string;
    charity_id: string;
    generated_by: string;
    total_donations: number;
    total_quantity: number;
    generated_at: number;
  };

  expect(data.total_donations).toBe(2);
  expect(data.total_quantity).toBe(15);
  expect(data.charity_id).toBe(CHARITY_A);
  expect(data.generated_by).toBe(adminUid);
  expect(data.generated_at).toBeTruthy();

  const snap = await admin.firestore().doc(`Reports/${data.report_id}`).get();
  expect(snap.exists).toBe(true);
  expect(snap.get('charity_id')).toBe(CHARITY_A);
  expect(snap.get('report_type')).toBe('categoryDetail');
  expect(snap.get('total_donations')).toBe(2);
  expect(snap.get('total_quantity')).toBe(15);
});

test('a non-admin cannot call the callable', async () => {
  const uid = 'reportDonor1';
  const functions = await functionsFor(uid, { role: 'donor' });
  const call = httpsCallable(functions, 'generateReport');

  await expect(
    call({
      report_type: 'categoryDetail',
      period_start: Date.now() - 1000,
      period_end: Date.now(),
    }),
  ).rejects.toMatchObject({ code: 'functions/permission-denied' });
});

test('rejects an invalid report_type', async () => {
  const adminUid = 'reportAdmin2';
  await seedAdmin(adminUid);
  const functions = await functionsFor(adminUid, { role: 'charity_admin' });
  const call = httpsCallable(functions, 'generateReport');

  await expect(
    call({
      report_type: 'not_a_real_type',
      period_start: Date.now() - 1000,
      period_end: Date.now(),
    }),
  ).rejects.toMatchObject({ code: 'functions/invalid-argument' });
});
