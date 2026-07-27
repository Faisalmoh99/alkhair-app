import * as admin from 'firebase-admin';
import { FieldValue } from 'firebase-admin/firestore';
import { logger } from 'firebase-functions/v2';
import { onDocumentWritten } from 'firebase-functions/v2/firestore';
import { REGION } from './region';

if (admin.apps.length === 0) {
  admin.initializeApp();
}

// Firestore-trigger functions MUST be deployed in the same region as the
// Firestore database (see region.ts for why that's europe-west1, not the
// originally-documented me-central2).

// The custom-claims shape mirrored onto the Auth token (SECURITY.md §2.1).
interface Claims {
  role?: string;
  approval_status?: string;
  charity_id?: string;
}

// Desired claims derived from the authoritative Firestore docs. Returns null
// when there is nothing to sync (no Users doc / no role yet).
async function computeDesiredClaims(uid: string): Promise<Claims | null> {
  const db = admin.firestore();
  const userSnap = await db.doc(`Users/${uid}`).get();
  if (!userSnap.exists) {
    return null;
  }
  const role = userSnap.get('role') as string | undefined;
  if (!role) {
    return null;
  }

  const claims: Claims = { role };
  // Volunteers additionally mirror approval_status + charity_id so rules and the
  // client can gate without an extra read.
  if (role === 'volunteer') {
    const volSnap = await db.doc(`Volunteers/${uid}`).get();
    if (volSnap.exists) {
      claims.approval_status = volSnap.get('approval_status');
      claims.charity_id = volSnap.get('charity_id');
    }
  }
  return claims;
}

function claimsEqual(a: Claims | undefined, b: Claims): boolean {
  const current = a ?? {};
  return (
    current.role === b.role &&
    current.approval_status === b.approval_status &&
    current.charity_id === b.charity_id
  );
}

// Idempotent claims sync. Writes the `claims_updated_at` refresh marker only when
// claims actually change — so the marker write re-triggering this function is a
// no-op and the loop terminates.
async function syncClaims(uid: string): Promise<void> {
  const desired = await computeDesiredClaims(uid);
  if (desired === null) {
    return;
  }

  let user: admin.auth.UserRecord;
  try {
    user = await admin.auth().getUser(uid);
  } catch (error) {
    // The Auth user may not exist yet (e.g. a seed script wrote the doc first).
    logger.warn(`syncClaims: no Auth user for ${uid}; skipping`, error);
    return;
  }

  const current = user.customClaims as Claims | undefined;
  if (claimsEqual(current, desired)) {
    return;
  }

  await admin.auth().setCustomUserClaims(uid, desired);
  await admin
    .firestore()
    .doc(`Users/${uid}`)
    .set({ claims_updated_at: FieldValue.serverTimestamp() }, { merge: true });
  logger.info(`Claims synced for ${uid}`, desired);
}

// Role is assigned/changed on the Users doc.
export const onUsersWrite = onDocumentWritten(
  { document: 'Users/{uid}', region: REGION },
  async (event) => {
    await syncClaims(event.params.uid);
  },
);

// Approval flips / charity assignment happen on the Volunteers doc; propagate
// them into claims + trip the client refresh marker.
export const onVolunteerWrite = onDocumentWritten(
  { document: 'Volunteers/{uid}', region: REGION },
  async (event) => {
    await syncClaims(event.params.uid);
  },
);
