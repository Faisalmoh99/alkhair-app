/**
 * Cloud Function tests (2b) — onUsersWrite / onVolunteerWrite.
 *
 * Emulator-based: writes docs via the Admin SDK and asserts the custom claims +
 * `claims_updated_at` marker the triggers produce (SECURITY.md §2.1).
 *
 * Run: npm --prefix functions run build && \
 *   firebase emulators:exec --only auth,firestore,functions --project=demo-alkhair \
 *     "npm --prefix functions run test:functions"
 */
import * as admin from 'firebase-admin';
import { Timestamp } from 'firebase-admin/firestore';

const PROJECT_ID = 'demo-alkhair';

beforeAll(() => {
  if (admin.apps.length === 0) {
    admin.initializeApp({ projectId: PROJECT_ID });
  }
});

interface Claims {
  role?: string;
  approval_status?: string;
  charity_id?: string;
}

async function waitForClaims(
  uid: string,
  predicate: (c: Claims) => boolean,
  timeoutMs = 15000,
): Promise<Claims> {
  const start = Date.now();
  while (Date.now() - start < timeoutMs) {
    const user = await admin.auth().getUser(uid);
    const claims = (user.customClaims ?? {}) as Claims;
    if (predicate(claims)) {
      return claims;
    }
    await new Promise((r) => setTimeout(r, 300));
  }
  throw new Error(`claims for ${uid} not set within ${timeoutMs}ms`);
}

async function waitForDoc(
  path: string,
  predicate: (d: FirebaseFirestore.DocumentData) => boolean,
  timeoutMs = 15000,
): Promise<FirebaseFirestore.DocumentData> {
  const start = Date.now();
  while (Date.now() - start < timeoutMs) {
    const snap = await admin.firestore().doc(path).get();
    const data = snap.data() ?? {};
    if (predicate(data)) {
      return data;
    }
    await new Promise((r) => setTimeout(r, 300));
  }
  throw new Error(`doc ${path} predicate unmet within ${timeoutMs}ms`);
}

test('onUsersWrite sets the donor role claim and writes the refresh marker', async () => {
  const uid = 'fnDonor';
  await admin.auth().createUser({ uid });
  await admin.firestore().doc(`Users/${uid}`).set({
    user_id: uid,
    name: 'Donor',
    phone: '+966500000001',
    role: 'donor',
    created_at: admin.firestore.FieldValue.serverTimestamp(),
  });

  const claims = await waitForClaims(uid, (c) => c.role === 'donor');
  expect(claims.role).toBe('donor');

  const marker = await waitForDoc(
    `Users/${uid}`,
    (d) => d.claims_updated_at != null,
  );
  expect(marker.claims_updated_at).toBeTruthy();
});

test('onVolunteerWrite mirrors approval_status + charity_id into claims', async () => {
  const uid = 'fnVol';
  await admin.auth().createUser({ uid });
  await admin.firestore().doc(`Users/${uid}`).set({
    user_id: uid,
    name: 'Volunteer',
    phone: '+966500000002',
    role: 'volunteer',
    created_at: admin.firestore.FieldValue.serverTimestamp(),
  });
  await admin.firestore().doc(`Volunteers/${uid}`).set({
    user_id: uid,
    charity_id: 'charityA',
    approval_status: 'approved',
    vehicle_type: 'car',
    current_lat: null,
    current_lng: null,
  });

  const claims = await waitForClaims(uid, (c) => c.approval_status === 'approved');
  expect(claims.role).toBe('volunteer');
  expect(claims.approval_status).toBe('approved');
  expect(claims.charity_id).toBe('charityA');
});

test('onUsersWrite sets the charity_admin claim (out-of-band provisioning)', async () => {
  // Simulates the platform owner provisioning an admin: a Users doc with
  // role=charity_admin is written directly (no public path, SECURITY.md §1.1).
  const uid = 'fnAdmin';
  await admin.auth().createUser({ uid });
  await admin.firestore().doc(`Users/${uid}`).set({
    user_id: uid,
    name: 'Charity Admin',
    phone: '+966500000003',
    role: 'charity_admin',
    created_at: admin.firestore.FieldValue.serverTimestamp(),
  });

  const claims = await waitForClaims(uid, (c) => c.role === 'charity_admin');
  expect(claims.role).toBe('charity_admin');
  // Admins carry no volunteer-only claims.
  expect(claims.approval_status).toBeUndefined();
  expect(claims.charity_id).toBeUndefined();
});

test(
  'writing only claims_updated_at does NOT re-trigger claim setting (loop guard)',
  async () => {
    // See SECURITY.md §2.1 — the marker write re-fires onUsersWrite; the guard
    // must short-circuit when claims are already up to date so it does not loop.
    const uid = 'fnLoop';
    await admin.auth().createUser({ uid });
    await admin.firestore().doc(`Users/${uid}`).set({
      user_id: uid,
      name: 'Loop',
      phone: '+966500000004',
      role: 'donor',
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Let the initial sync finish (claim + marker written exactly once).
    await waitForClaims(uid, (c) => c.role === 'donor');
    await waitForDoc(`Users/${uid}`, (d) => d.claims_updated_at != null);

    // Overwrite ONLY the marker with a sentinel; role/other fields unchanged.
    const sentinel = Timestamp.fromMillis(1);
    await admin
      .firestore()
      .doc(`Users/${uid}`)
      .update({ claims_updated_at: sentinel });

    // Give the trigger ample time to (not) run.
    await new Promise((r) => setTimeout(r, 3000));

    // Short-circuited: the function did NOT overwrite the sentinel with a fresh
    // serverTimestamp. If the guard were broken, this would be "now" (ms >> 1).
    const snap = await admin.firestore().doc(`Users/${uid}`).get();
    const marker = snap.get('claims_updated_at') as Timestamp;
    expect(marker.toMillis()).toBe(1);
  },
  20000,
);

