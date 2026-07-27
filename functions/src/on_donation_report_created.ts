import * as admin from 'firebase-admin';
import { FieldValue } from 'firebase-admin/firestore';
import { logger } from 'firebase-functions/v2';
import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { REGION } from './region';

if (admin.apps.length === 0) {
  admin.initializeApp();
}

// Firestore-trigger functions MUST be deployed in the same region as the
// Firestore database (see region.ts).

// Volunteer dispatch radius (FR6 — "configurable radius"). Mirrors the Dart
// constant kDefaultDispatchRadiusKm (lib/core/constants/app_constants.dart) —
// kept in sync by hand since the two runtimes can't share a constant, same
// treatment as MAX_QUANTITY in create_donation_report.ts.
const DISPATCH_RADIUS_KM = 10;

const EARTH_RADIUS_KM = 6371;

function toRadians(deg: number): number {
  return (deg * Math.PI) / 180;
}

// Great-circle distance between two lat/lng points, in kilometers.
function haversineDistanceKm(
  lat1: number,
  lng1: number,
  lat2: number,
  lng2: number,
): number {
  const dLat = toRadians(lat2 - lat1);
  const dLng = toRadians(lng2 - lng1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRadians(lat1)) * Math.cos(toRadians(lat2)) * Math.sin(dLng / 2) ** 2;
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return EARTH_RADIUS_KM * c;
}

// Volunteer dispatch (FR6, Fig 4.1 delay point 1). On a new DonationReport,
// finds approved volunteers with a known location within DISPATCH_RADIUS_KM
// and writes each a Notifications doc. Firestore has no native geo-range
// query here, so candidates (already narrowed to approval_status=="approved")
// are filtered in memory — acceptable at this project's scale (ASSUMPTION,
// flagged like the rate-limit/quantity constants).
//
// FCM push is intentionally NOT sent here: no `fcm_token` field exists in the
// data dictionary (Tables 4.2-4.8), and adding one now would be an
// undocumented schema change. The Notifications doc alone drives Screen 4 via
// a Firestore stream, which satisfies FR6's real-time intent while the app is
// foregrounded. Real push delivery is deferred to when Track B unblocks and
// the token field can be documented properly.
export const onDonationReportCreated = onDocumentCreated(
  { document: 'DonationReports/{reportId}', region: REGION },
  async (event) => {
    const snap = event.data;
    if (!snap) {
      return;
    }
    const report = snap.data();
    if (report.status !== 'reported') {
      return;
    }

    const reportId = event.params.reportId;
    const db = admin.firestore();

    const volunteersSnap = await db
      .collection('Volunteers')
      .where('approval_status', '==', 'approved')
      .get();

    const nearby = volunteersSnap.docs.filter((doc) => {
      const lat = doc.get('current_lat');
      const lng = doc.get('current_lng');
      if (typeof lat !== 'number' || typeof lng !== 'number') {
        return false;
      }
      const distanceKm = haversineDistanceKm(lat, lng, report.latitude, report.longitude);
      return distanceKm <= DISPATCH_RADIUS_KM;
    });

    if (nearby.length === 0) {
      logger.info(`No nearby approved volunteers for report ${reportId}`);
      return;
    }

    const batch = db.batch();
    for (const volunteerDoc of nearby) {
      const notificationRef = db.collection('Notifications').doc();
      batch.set(notificationRef, {
        notification_id: notificationRef.id,
        user_id: volunteerDoc.id,
        report_id: reportId,
        message: 'بلاغ جديد عن فائض غذائي بالقرب منك.',
        type: 'new_donation_alert',
        is_read: false,
        created_at: FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();

    logger.info(`Dispatched report ${reportId} to ${nearby.length} nearby volunteer(s)`);
  },
);
