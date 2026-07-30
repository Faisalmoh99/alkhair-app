/**
 * Cloud Function test — checkPhoneRegistered callable (sign-up duplicate-phone
 * uniqueness check, ARCHITECTURE.md §6).
 *
 * Phone numbers must stay unique across Users even though they are no longer
 * verified. Firestore rules only let a client read its own Users doc, so
 * this is done server-side with the Admin SDK, before account creation.
 *
 * Run: npm --prefix functions run build && \
 *   firebase emulators:exec --only auth,firestore,functions --project=demo-alkhair \
 *     "npm --prefix functions run test:functions"
 */
import { initializeApp } from 'firebase/app';
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

// No sign-in: this runs before account creation, so before any account
// exists for the caller.
function anonymousFunctions() {
  const app = initializeApp(
    { projectId: PROJECT_ID, apiKey: 'fake-api-key' },
    `test-${PROJECT_ID}-${clientCounter++}`,
  );
  const functions = getFunctions(app, REGION);
  connectFunctionsEmulator(functions, '127.0.0.1', 5001);
  return functions;
}

test('registered: true for a phone already on a Users doc', async () => {
  await admin.firestore().doc('Users/cprUser1').set({
    user_id: 'cprUser1',
    name: 'Faisal',
    phone: '+966502222222',
    username: 'cpr_known',
    role: 'donor',
    created_at: admin.firestore.FieldValue.serverTimestamp(),
  });

  const call = httpsCallable(anonymousFunctions(), 'checkPhoneRegistered');
  const result = await call({ phone: '+966502222222' });

  expect((result.data as { registered: boolean }).registered).toBe(true);
});

test('registered: false for a phone with no Users doc', async () => {
  const call = httpsCallable(anonymousFunctions(), 'checkPhoneRegistered');

  const result = await call({ phone: '+966503333333' });

  expect((result.data as { registered: boolean }).registered).toBe(false);
});

test(
  'rate limit rejects repeated checks against the same phone with RATE_LIMIT_EXCEEDED',
  async () => {
    const call = httpsCallable(anonymousFunctions(), 'checkPhoneRegistered');
    const phone = '+966504444444';

    for (let i = 0; i < 5; i++) {
      await call({ phone });
    }

    try {
      await call({ phone });
      throw new Error('expected the 6th check to be rejected');
    } catch (e) {
      expect((e as { code: string }).code).toBe('functions/resource-exhausted');
      expect((e as { details?: { code?: string } }).details).toMatchObject({
        code: 'RATE_LIMIT_EXCEEDED',
      });
    }
  },
  30000,
);
