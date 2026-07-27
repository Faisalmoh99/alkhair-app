import * as admin from 'firebase-admin';
import { FieldValue, Timestamp } from 'firebase-admin/firestore';
import { logger } from 'firebase-functions/v2';
import { HttpsError, onCall } from 'firebase-functions/v2/https';
import { REGION } from './region';

if (admin.apps.length === 0) {
  admin.initializeApp();
}

// Rate-limit tuning (SECURITY.md §3). No numeric limit/window is specified in
// the governing docs for report creation — flagged default, easy to tune.
const RATE_LIMIT = 20;
const RATE_LIMIT_WINDOW_MS = 60 * 60 * 1000; // 1 hour

const FOOD_CATEGORIES = [
  'main_meals',
  'baked_goods',
  'fruits_and_vegetables',
  'canned',
  'other',
];
const MAX_QUANTITY = 100000;

interface ValidatedPayload {
  food_category: string;
  quantity: number;
  readiness_time: number; // epoch millis
  latitude: number;
  longitude: number;
}

interface RateLimitCounter {
  window_start: number;
  count: number;
  limit: number;
}

// Server re-validation (SECURITY.md §4): every field the client already
// checked is re-checked here, since firestore.rules denies direct client
// create on DonationReports — this Function is the only write path.
function validate(payload: unknown): ValidatedPayload {
  if (typeof payload !== 'object' || payload === null) {
    throw new HttpsError('invalid-argument', 'Malformed request.', {
      code: 'VALIDATION_FAILED',
    });
  }
  const p = payload as Record<string, unknown>;

  if (typeof p.food_category !== 'string' || !FOOD_CATEGORIES.includes(p.food_category)) {
    throw new HttpsError('invalid-argument', 'Invalid food_category.', {
      code: 'VALIDATION_FAILED',
    });
  }
  if (typeof p.quantity !== 'number' || !(p.quantity > 0) || p.quantity > MAX_QUANTITY) {
    throw new HttpsError('invalid-argument', 'Invalid quantity.', {
      code: 'VALIDATION_FAILED',
    });
  }
  if (typeof p.latitude !== 'number' || p.latitude < -90 || p.latitude > 90) {
    throw new HttpsError('invalid-argument', 'Invalid latitude.', {
      code: 'VALIDATION_FAILED',
    });
  }
  if (typeof p.longitude !== 'number' || p.longitude < -180 || p.longitude > 180) {
    throw new HttpsError('invalid-argument', 'Invalid longitude.', {
      code: 'VALIDATION_FAILED',
    });
  }
  if (typeof p.readiness_time !== 'number' || !Number.isFinite(p.readiness_time)) {
    throw new HttpsError('invalid-argument', 'Invalid readiness_time.', {
      code: 'VALIDATION_FAILED',
    });
  }
  if (p.safety_confirmed !== true) {
    throw new HttpsError('invalid-argument', 'safety_confirmed must be true.', {
      code: 'VALIDATION_FAILED',
    });
  }

  return {
    food_category: p.food_category,
    quantity: p.quantity,
    readiness_time: p.readiness_time,
    latitude: p.latitude,
    longitude: p.longitude,
  };
}

// Donor report creation (FR2/FR3/FR4). Enforces a per-donor rate limit via a
// transactional counter (SECURITY.md §3) and re-validates every field
// (SECURITY.md §4) before writing DonationReports with the Admin SDK.
// firestore.rules denies direct client create on this collection, so this is
// the only creation path — a rejected rate-limit check writes no report
// because the counter update and the report write share one transaction.
export const createDonationReport = onCall({ region: REGION }, async (request) => {
  const uid = request.auth?.uid;
  if (!uid || request.auth?.token.role !== 'donor') {
    throw new HttpsError('permission-denied', 'Only donors may report surplus food.');
  }

  const data = validate(request.data);
  const db = admin.firestore();
  const counterRef = db.doc(`RateLimits/report_${uid}`);
  const reportRef = db.collection('DonationReports').doc();

  await db.runTransaction(async (tx) => {
    const now = Date.now();
    const counterSnap = await tx.get(counterRef);
    const counter = counterSnap.data() as RateLimitCounter | undefined;

    let windowStart = now;
    let count = 1;
    if (counter && now - counter.window_start < RATE_LIMIT_WINDOW_MS) {
      if (counter.count >= RATE_LIMIT) {
        throw new HttpsError('resource-exhausted', 'Rate limit exceeded.', {
          code: 'RATE_LIMIT_EXCEEDED',
        });
      }
      windowStart = counter.window_start;
      count = counter.count + 1;
    }

    tx.set(counterRef, { window_start: windowStart, count, limit: RATE_LIMIT });
    tx.set(reportRef, {
      report_id: reportRef.id,
      donor_id: uid,
      volunteer_id: null,
      food_category: data.food_category,
      quantity: data.quantity,
      readiness_time: Timestamp.fromMillis(data.readiness_time),
      latitude: data.latitude,
      longitude: data.longitude,
      safety_confirmed: true,
      status: 'reported',
      created_at: FieldValue.serverTimestamp(),
    });
  });

  logger.info(`DonationReport created by ${uid}`, { report_id: reportRef.id });
  return { report_id: reportRef.id };
});
