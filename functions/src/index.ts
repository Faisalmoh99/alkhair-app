/**
 * Al-Khair Cloud Functions entry point.
 *
 * Phase 2: Custom Claims sync (role, and for volunteers approval_status +
 * charity_id) with a forced-refresh marker. See SECURITY.md §2.1.
 *
 * Phase 3: donor report creation with rate limiting + double validation.
 * See SECURITY.md §3/§4.
 *
 * Phase 4: volunteer dispatch on new donation reports (FR6). Reassignment /
 * timeout / expiry (Fig 4.5) is deferred to Phase 4b — see ARCHITECTURE.md §6.
 *
 * Phase 6: server-side report aggregation (FR12) — writes the Reports
 * collection (Table 4.8) on export; the read-side screens aggregate live.
 */
export { onUsersWrite, onVolunteerWrite } from './on_users_write';
export { createDonationReport } from './create_donation_report';
export { onDonationReportCreated } from './on_donation_report_created';
export { generateReport } from './generate_report';
