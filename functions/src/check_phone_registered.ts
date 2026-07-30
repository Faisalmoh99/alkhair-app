import * as admin from 'firebase-admin';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { REGION } from './region';

if (admin.apps.length === 0) {
  admin.initializeApp();
}

// Rate-limit tuning: keyed by the *requested phone* (not the caller, who is
// unauthenticated here).
const RATE_LIMIT = 5;
const RATE_LIMIT_WINDOW_MS = 60 * 60 * 1000; // 1 hour

interface RateLimitCounter {
  window_start: number;
  count: number;
  limit: number;
}

// Sign-up duplicate-phone pre-check (ARCHITECTURE.md §6): phone numbers must
// stay unique across Users even though they are no longer verified.
// Firestore rules only allow reading one's own Users doc, so this callable
// does the lookup server-side with the Admin SDK, before account creation.
export const checkPhoneRegistered = onCall({ region: REGION }, async (request) => {
  const phone = request.data?.phone;
  if (typeof phone !== 'string' || phone.trim().length === 0) {
    throw new HttpsError('invalid-argument', 'phone is required.');
  }

  const db = admin.firestore();
  const counterRef = db.doc(`RateLimits/phone_check_${phone}`);

  const limited = await db.runTransaction(async (tx) => {
    const now = Date.now();
    const counterSnap = await tx.get(counterRef);
    const counter = counterSnap.data() as RateLimitCounter | undefined;

    let windowStart = now;
    let count = 1;
    if (counter && now - counter.window_start < RATE_LIMIT_WINDOW_MS) {
      if (counter.count >= RATE_LIMIT) {
        return true;
      }
      windowStart = counter.window_start;
      count = counter.count + 1;
    }

    tx.set(counterRef, { window_start: windowStart, count, limit: RATE_LIMIT });
    return false;
  });

  if (limited) {
    throw new HttpsError('resource-exhausted', 'Too many attempts.', {
      code: 'RATE_LIMIT_EXCEEDED',
    });
  }

  const snap = await db.collection('Users').where('phone', '==', phone).limit(1).get();

  return { registered: !snap.empty };
});
