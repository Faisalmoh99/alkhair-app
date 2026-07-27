/**
 * Cloud Function tests — createDonationReport callable (Phase 3).
 *
 * Emulator-based via the client SDK (mirrors what the Flutter app calls):
 * asserts the happy-path write, the rate-limit transaction rejects on breach
 * with RATE_LIMIT_EXCEEDED, and server re-validation rejects a bypassed
 * client (SECURITY.md §3, §4; TEST_PLAN.md Phase 3 Function/Rules tests).
 *
 * Run: npm --prefix functions run build && \
 *   firebase emulators:exec --only auth,firestore,functions --project=demo-alkhair \
 *     "npm --prefix functions run test:functions"
 */
import { initializeApp } from 'firebase/app';
import { connectAuthEmulator, getAuth, signInWithCustomToken } from 'firebase/auth';
import { connectFunctionsEmulator, getFunctions, httpsCallable } from 'firebase/functions';
import * as admin from 'firebase-admin';
import { REGION } from '../src/region';

const PROJECT_ID = 'demo-alkhair';

beforeAll(() => {
  if (admin.apps.length === 0) {
    admin.initializeApp({ projectId: PROJECT_ID });
  }
});

let clientCounter = 0;

// Signs in as a fresh donor uid via a custom token carrying the `role` claim
// (mirrors how onUsersWrite sets it in production) and returns a Functions
// instance ready to call the callable in the given region.
async function donorFunctions(uid: string) {
  const token = await admin.auth().createCustomToken(uid, { role: 'donor' });

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

function validPayload(overrides: Record<string, unknown> = {}) {
  return {
    food_category: 'main_meals',
    quantity: 5,
    readiness_time: Date.now() + 3600_000,
    latitude: 20.0,
    longitude: 42.5,
    safety_confirmed: true,
    ...overrides,
  };
}

test('happy path writes a DonationReports doc via the callable', async () => {
  const functions = await donorFunctions('cbDonor1');
  const call = httpsCallable(functions, 'createDonationReport');

  const result = await call(validPayload());
  const reportId = (result.data as { report_id: string }).report_id;

  const snap = await admin.firestore().doc(`DonationReports/${reportId}`).get();
  expect(snap.exists).toBe(true);
  expect(snap.get('status')).toBe('reported');
  expect(snap.get('donor_id')).toBe('cbDonor1');
  expect(snap.get('volunteer_id')).toBeNull();
  expect(snap.get('created_at')).toBeTruthy();
});

test(
  'rate limit rejects the next call past the per-donor cap with RATE_LIMIT_EXCEEDED',
  async () => {
    const functions = await donorFunctions('cbDonor2');
    const call = httpsCallable(functions, 'createDonationReport');

    for (let i = 0; i < 20; i++) {
      await call(validPayload());
    }

    try {
      await call(validPayload());
      throw new Error('expected the 21st call to be rejected');
    } catch (e) {
      expect((e as { code: string }).code).toBe('functions/resource-exhausted');
      expect((e as { details?: { code?: string } }).details).toMatchObject({
        code: 'RATE_LIMIT_EXCEEDED',
      });
    }
  },
  30000,
);

test('server re-validates quantity/lat/lng/safety_confirmed even if the client bypasses them', async () => {
  const functions = await donorFunctions('cbDonor3');
  const call = httpsCallable(functions, 'createDonationReport');

  for (const overrides of [
    { quantity: 0 },
    { latitude: 200 },
    { longitude: -200 },
    { safety_confirmed: false },
    { food_category: 'not_a_real_category' },
  ]) {
    try {
      await call(validPayload(overrides));
      throw new Error(`expected rejection for ${JSON.stringify(overrides)}`);
    } catch (e) {
      expect((e as { code: string }).code).toBe('functions/invalid-argument');
      expect((e as { details?: { code?: string } }).details).toMatchObject({
        code: 'VALIDATION_FAILED',
      });
    }
  }
});

test('a non-donor cannot call the callable', async () => {
  const uid = 'cbVol1';
  const token = await admin.auth().createCustomToken(uid, { role: 'volunteer' });
  const app = initializeApp(
    { projectId: PROJECT_ID, apiKey: 'fake-api-key' },
    `test-${PROJECT_ID}-${clientCounter++}`,
  );
  const auth = getAuth(app);
  connectAuthEmulator(auth, 'http://127.0.0.1:9099', { disableWarnings: true });
  await signInWithCustomToken(auth, token);
  const functions = getFunctions(app, REGION);
  connectFunctionsEmulator(functions, '127.0.0.1', 5001);

  const call = httpsCallable(functions, 'createDonationReport');
  await expect(call(validPayload())).rejects.toMatchObject({
    code: 'functions/permission-denied',
  });
});
