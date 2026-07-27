// Single source of truth for the Cloud Functions / Firestore region.
//
// Originally me-central2 (Dammam) per Chapter Four's KSA data-residency intent,
// but me-central2 is sales-gated for Cloud Functions/Cloud Run/Eventarc
// (requires a Google data-sovereignty agreement not obtainable before the
// submission deadline). Firestore direct-event triggers also require the
// trigger and database to be in the same single-region location, so the
// database was relocated here too — both data-at-rest and compute now live in
// europe-west1. See ARCHITECTURE.md §6.
export const REGION = 'europe-west1';
