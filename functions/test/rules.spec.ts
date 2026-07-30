/**
 * Firestore Rules Unit Tests — THE PHASE-2 SECURITY GATE.
 *
 * Proves `firestore.rules` against the Firestore emulator BEFORE any screen is
 * built (SECURITY.md §8, TEST_PLAN.md §Phase 2 "2a"). Every case traces to the
 * rule→data-dictionary mapping in SECURITY.md §2.2.
 *
 * Run: firebase emulators:exec --only firestore --project=demo-alkhair \
 *        "npm --prefix functions run test:rules"
 */
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  collection,
  doc,
  deleteDoc,
  getDoc,
  getDocs,
  query,
  serverTimestamp,
  setDoc,
  Timestamp,
  updateDoc,
  where,
} from 'firebase/firestore';
import { readFileSync } from 'fs';
import { resolve } from 'path';

const PROJECT_ID = 'demo-alkhair';
const CHARITY_A = 'charityA';
const CHARITY_B = 'charityB';
const FIXED_TS = Timestamp.fromMillis(1_700_000_000_000);

let testEnv: RulesTestEnvironment;

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules: readFileSync(resolve(__dirname, '../../firestore.rules'), 'utf8'),
      host: '127.0.0.1',
      port: 8085,
    },
  });
});

afterAll(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
});

// --- context helpers ---------------------------------------------------------
function donorCtx(uid = 'donor1') {
  return testEnv.authenticatedContext(uid, { role: 'donor' }).firestore();
}
function volunteerCtx(uid = 'vol1') {
  return testEnv.authenticatedContext(uid, { role: 'volunteer' }).firestore();
}
function adminCtx(uid = 'admin1') {
  return testEnv.authenticatedContext(uid, { role: 'charity_admin' }).firestore();
}
function anonCtx() {
  return testEnv.unauthenticatedContext().firestore();
}

// --- seed helper (rules disabled) -------------------------------------------
async function seed(fn: (db: any) => Promise<void>) {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await fn(ctx.firestore());
  });
}

async function seedApprovedVolunteer(uid: string, charityId = CHARITY_A) {
  await seed(async (db) => {
    await setDoc(doc(db, `Volunteers/${uid}`), {
      user_id: uid,
      charity_id: charityId,
      approval_status: 'approved',
      vehicle_type: 'car',
      current_lat: null,
      current_lng: null,
    });
  });
}

async function seedAdmin(uid: string, charityId = CHARITY_A) {
  await seed(async (db) => {
    await setDoc(doc(db, `CharityAdmins/${uid}`), {
      user_id: uid,
      charity_id: charityId,
    });
  });
}

function reportData(overrides: Record<string, unknown> = {}) {
  return {
    report_id: 'rep1',
    donor_id: 'donor1',
    volunteer_id: null,
    food_category: 'main_meals',
    quantity: 5,
    readiness_time: FIXED_TS,
    latitude: 20.0,
    longitude: 42.5,
    safety_confirmed: true,
    status: 'reported',
    created_at: FIXED_TS,
    ...overrides,
  };
}

// =============================================================================
// Users (Table 4.2)
// =============================================================================
describe('Users', () => {
  const validCreate = () => ({
    user_id: 'donor1',
    name: 'Faisal',
    phone: '+966500000000',
    username: 'faisal',
    role: 'donor',
    created_at: serverTimestamp(),
  });

  it('owner self-creates a valid Users doc', async () => {
    await assertSucceeds(setDoc(doc(donorCtx(), 'Users/donor1'), validCreate()));
  });

  it('rejects creating another user\'s doc', async () => {
    await assertFails(setDoc(doc(donorCtx('donor1'), 'Users/someoneElse'), validCreate()));
  });

  it('rejects password_hash on create', async () => {
    await assertFails(
      setDoc(doc(donorCtx(), 'Users/donor1'), {
        ...validCreate(),
        password_hash: 'x',
      }),
    );
  });

  it('rejects an illegal role value', async () => {
    await assertFails(
      setDoc(doc(donorCtx(), 'Users/donor1'), { ...validCreate(), role: 'superuser' }),
    );
  });

  // Username+password migration (ARCHITECTURE.md §6): charity_admin is
  // provisioned out-of-band only — self-signup no longer offers that role,
  // and the rule itself must reject it even if a client tried to bypass the UI.
  it('rejects charity_admin self-create (provisioned out-of-band only)', async () => {
    await assertFails(
      setDoc(doc(donorCtx(), 'Users/donor1'), { ...validCreate(), role: 'charity_admin' }),
    );
  });

  // Phone/OTP verification removed (ARCHITECTURE.md §6): phone is a plain,
  // unverified data field, so phone_verified is no longer part of the
  // schema and is rejected as an unexpected key.
  it('rejects a doc containing phone_verified (no longer part of the schema)', async () => {
    await assertFails(
      setDoc(doc(donorCtx(), 'Users/donor1'), { ...validCreate(), phone_verified: true }),
    );
  });

  it('rejects create without a username', async () => {
    const withoutUsername: Record<string, unknown> = validCreate();
    delete withoutUsername.username;
    await assertFails(setDoc(doc(donorCtx(), 'Users/donor1'), withoutUsername));
  });

  it('rejects an unexpected extra key (hasOnly)', async () => {
    await assertFails(
      setDoc(doc(donorCtx(), 'Users/donor1'), { ...validCreate(), donorType: 'gold' }),
    );
  });

  it('rejects a client-supplied (non-server) created_at', async () => {
    await assertFails(
      setDoc(doc(donorCtx(), 'Users/donor1'), { ...validCreate(), created_at: FIXED_TS }),
    );
  });

  it('owner reads own doc; stranger cannot; admin can', async () => {
    await seed(async (db) => {
      await setDoc(doc(db, 'Users/donor1'), {
        user_id: 'donor1',
        name: 'F',
        phone: '+9665',
        role: 'donor',
        created_at: FIXED_TS,
      });
    });
    await assertSucceeds(getDoc(doc(donorCtx('donor1'), 'Users/donor1')));
    await assertFails(getDoc(doc(donorCtx('intruder'), 'Users/donor1')));
    await assertSucceeds(getDoc(doc(adminCtx(), 'Users/donor1')));
  });

  it('owner updates name but cannot change role/user_id/created_at or add password_hash', async () => {
    await seed(async (db) => {
      await setDoc(doc(db, 'Users/donor1'), {
        user_id: 'donor1',
        name: 'F',
        phone: '+9665',
        role: 'donor',
        created_at: FIXED_TS,
      });
    });
    await assertSucceeds(updateDoc(doc(donorCtx(), 'Users/donor1'), { name: 'New' }));
    await assertFails(updateDoc(doc(donorCtx(), 'Users/donor1'), { role: 'charity_admin' }));
    await assertFails(updateDoc(doc(donorCtx(), 'Users/donor1'), { user_id: 'x' }));
    await assertFails(updateDoc(doc(donorCtx(), 'Users/donor1'), { created_at: serverTimestamp() }));
    await assertFails(updateDoc(doc(donorCtx(), 'Users/donor1'), { password_hash: 'x' }));
  });

  it('volunteer extra-step: owner may add email via update', async () => {
    await seed(async (db) => {
      await setDoc(doc(db, 'Users/vol1'), {
        user_id: 'vol1',
        name: 'V',
        phone: '+9665',
        role: 'volunteer',
        created_at: FIXED_TS,
      });
    });
    await assertSucceeds(
      updateDoc(doc(volunteerCtx('vol1'), 'Users/vol1'), { email: 'v@x.com' }),
    );
  });

  it('forbids delete (permanent record, FR13)', async () => {
    await seed(async (db) => {
      await setDoc(doc(db, 'Users/donor1'), {
        user_id: 'donor1',
        name: 'F',
        phone: '+9665',
        role: 'donor',
        created_at: FIXED_TS,
      });
    });
    await assertFails(deleteDoc(doc(donorCtx(), 'Users/donor1')));
  });
});

// =============================================================================
// Volunteers (Table 4.3)
// =============================================================================
describe('Volunteers', () => {
  const pendingCreate = (uid = 'vol1') => ({
    user_id: uid,
    charity_id: CHARITY_A,
    approval_status: 'pending',
    vehicle_type: 'car',
    current_lat: null,
    current_lng: null,
  });

  it('owner self-creates sub-doc with approval_status=pending', async () => {
    await assertSucceeds(setDoc(doc(volunteerCtx('vol1'), 'Volunteers/vol1'), pendingCreate()));
  });

  it('rejects self-create that pre-sets approval_status=approved', async () => {
    await assertFails(
      setDoc(doc(volunteerCtx('vol1'), 'Volunteers/vol1'), {
        ...pendingCreate(),
        approval_status: 'approved',
      }),
    );
  });

  it('rejects creating a sub-doc for another uid', async () => {
    await assertFails(
      setDoc(doc(volunteerCtx('vol1'), 'Volunteers/other'), pendingCreate('other')),
    );
  });

  it('owner updates location only; cannot self-approve', async () => {
    await seed(async (db) => {
      await setDoc(doc(db, 'Volunteers/vol1'), pendingCreate());
    });
    await assertSucceeds(
      updateDoc(doc(volunteerCtx('vol1'), 'Volunteers/vol1'), {
        current_lat: 20.1,
        current_lng: 42.6,
      }),
    );
    await assertFails(
      updateDoc(doc(volunteerCtx('vol1'), 'Volunteers/vol1'), { approval_status: 'approved' }),
    );
  });

  it('owner cannot smuggle a vehicle_type change into a location update', async () => {
    await seed(async (db) => {
      await setDoc(doc(db, 'Volunteers/vol1'), pendingCreate());
    });
    await assertFails(
      updateDoc(doc(volunteerCtx('vol1'), 'Volunteers/vol1'), {
        current_lat: 20.1,
        current_lng: 42.6,
        vehicle_type: 'truck',
      }),
    );
  });

  it('same-charity admin flips approval_status; other-charity admin cannot', async () => {
    await seed(async (db) => {
      await setDoc(doc(db, 'Volunteers/vol1'), pendingCreate());
    });
    await seedAdmin('admin1', CHARITY_A);
    await seedAdmin('admin2', CHARITY_B);
    await assertSucceeds(
      updateDoc(doc(adminCtx('admin1'), 'Volunteers/vol1'), { approval_status: 'approved' }),
    );
    await assertFails(
      updateDoc(doc(adminCtx('admin2'), 'Volunteers/vol1'), { approval_status: 'revoked' }),
    );
  });

  it('a donor cannot flip approval_status', async () => {
    await seed(async (db) => {
      await setDoc(doc(db, 'Volunteers/vol1'), pendingCreate());
    });
    await assertFails(
      updateDoc(doc(donorCtx('donor1'), 'Volunteers/vol1'), { approval_status: 'approved' }),
    );
  });

  it('read: owner + admin allowed; unrelated volunteer denied', async () => {
    await seed(async (db) => {
      await setDoc(doc(db, 'Volunteers/vol1'), pendingCreate());
    });
    await assertSucceeds(getDoc(doc(volunteerCtx('vol1'), 'Volunteers/vol1')));
    await assertSucceeds(getDoc(doc(adminCtx(), 'Volunteers/vol1')));
    await assertFails(getDoc(doc(volunteerCtx('vol2'), 'Volunteers/vol1')));
  });

  it('forbids delete', async () => {
    await seed(async (db) => {
      await setDoc(doc(db, 'Volunteers/vol1'), pendingCreate());
    });
    await assertFails(deleteDoc(doc(volunteerCtx('vol1'), 'Volunteers/vol1')));
  });
});

// =============================================================================
// CharityAdmins (Table 4.4) — out-of-band provisioning only
// =============================================================================
describe('CharityAdmins', () => {
  it('rejects all client create/update/delete', async () => {
    await assertFails(
      setDoc(doc(adminCtx('admin1'), 'CharityAdmins/admin1'), {
        user_id: 'admin1',
        charity_id: CHARITY_A,
      }),
    );
    await seedAdmin('admin1', CHARITY_A);
    await assertFails(
      updateDoc(doc(adminCtx('admin1'), 'CharityAdmins/admin1'), { charity_id: CHARITY_B }),
    );
    await assertFails(deleteDoc(doc(adminCtx('admin1'), 'CharityAdmins/admin1')));
  });

  it('owner may read own record', async () => {
    await seedAdmin('admin1', CHARITY_A);
    await assertSucceeds(getDoc(doc(adminCtx('admin1'), 'CharityAdmins/admin1')));
    await assertFails(getDoc(doc(adminCtx('admin2'), 'CharityAdmins/admin1')));
  });
});

// =============================================================================
// Charities (Table 4.5) — reference data
// =============================================================================
describe('Charities', () => {
  it('public read (even unauthenticated — the sign-up form loads this before '
      + 'auth exists); clients cannot write', async () => {
    await seed(async (db) => {
      await setDoc(doc(db, `Charities/${CHARITY_A}`), {
        charity_id: CHARITY_A,
        name: 'جمعية البر بمحافظة بيشة',
        registration_number: '123',
        address: 'بيشة',
      });
    });
    await assertSucceeds(getDoc(doc(donorCtx(), `Charities/${CHARITY_A}`)));
    await assertSucceeds(getDoc(doc(anonCtx(), `Charities/${CHARITY_A}`)));
    await assertFails(
      setDoc(doc(adminCtx(), 'Charities/new'), { charity_id: 'new', name: 'x' }),
    );
  });
});

// =============================================================================
// DonationReports (Table 4.6) — the core transaction
// =============================================================================
describe('DonationReports', () => {
  const create = (o: Record<string, unknown> = {}) => ({
    report_id: 'rep1',
    donor_id: 'donor1',
    food_category: 'main_meals',
    quantity: 5,
    readiness_time: FIXED_TS,
    latitude: 20.0,
    longitude: 42.5,
    safety_confirmed: true,
    status: 'reported',
    created_at: serverTimestamp(),
    ...o,
  });

  // Phase 3 (SECURITY.md §3): creation moved entirely into the
  // createDonationReport callable, which holds the transactional rate limit
  // and writes via the Admin SDK (bypassing these rules). Direct client
  // create — from any role, even with an otherwise-valid payload — must be
  // denied so the rate limiter cannot be bypassed by writing straight to
  // Firestore. Field-level re-validation (safety_confirmed, quantity,
  // lat/lng) now lives in the callable's own test, not here.
  it('rejects direct client create — server-only via createDonationReport callable', async () => {
    await assertFails(setDoc(doc(donorCtx('donor1'), 'DonationReports/rep1'), create()));
    await assertFails(setDoc(doc(volunteerCtx('vol1'), 'DonationReports/rep1'), create()));
  });

  it('unapproved volunteer cannot claim an open report', async () => {
    await seed(async (db) => {
      await setDoc(doc(db, 'DonationReports/rep1'), reportData());
    });
    // vol1 has role claim but no approved Volunteers doc.
    await assertFails(
      updateDoc(doc(volunteerCtx('vol1'), 'DonationReports/rep1'), {
        status: 'assigned',
        volunteer_id: 'vol1',
      }),
    );
  });

  it('approved volunteer claims an unassigned report and sets volunteer_id=self', async () => {
    await seed(async (db) => {
      await setDoc(doc(db, 'DonationReports/rep1'), reportData());
    });
    await seedApprovedVolunteer('vol1');
    await assertSucceeds(
      updateDoc(doc(volunteerCtx('vol1'), 'DonationReports/rep1'), {
        status: 'assigned',
        volunteer_id: 'vol1',
      }),
    );
  });

  it('approved volunteer cannot claim an already-assigned report', async () => {
    await seed(async (db) => {
      await setDoc(doc(db, 'DonationReports/rep1'), reportData({
        status: 'assigned',
        volunteer_id: 'volX',
      }));
    });
    await seedApprovedVolunteer('vol1');
    await assertFails(
      updateDoc(doc(volunteerCtx('vol1'), 'DonationReports/rep1'), {
        status: 'assigned',
        volunteer_id: 'vol1',
      }),
    );
  });

  it('assigned volunteer advances assigned→collected→delivered', async () => {
    await seed(async (db) => {
      await setDoc(doc(db, 'DonationReports/rep1'), reportData({
        status: 'assigned',
        volunteer_id: 'vol1',
      }));
    });
    await seedApprovedVolunteer('vol1');
    await assertSucceeds(
      updateDoc(doc(volunteerCtx('vol1'), 'DonationReports/rep1'), { status: 'collected' }),
    );
    await assertSucceeds(
      updateDoc(doc(volunteerCtx('vol1'), 'DonationReports/rep1'), { status: 'delivered' }),
    );
  });

  it('rejects an illegal status jump (reported→delivered)', async () => {
    await seed(async (db) => {
      await setDoc(doc(db, 'DonationReports/rep1'), reportData());
    });
    await seedApprovedVolunteer('vol1');
    await assertFails(
      updateDoc(doc(volunteerCtx('vol1'), 'DonationReports/rep1'), {
        status: 'delivered',
        volunteer_id: 'vol1',
      }),
    );
  });

  it('rejects a status reversal (collected→assigned)', async () => {
    await seed(async (db) => {
      await setDoc(doc(db, 'DonationReports/rep1'), reportData({
        status: 'collected',
        volunteer_id: 'vol1',
      }));
    });
    await seedApprovedVolunteer('vol1');
    await assertFails(
      updateDoc(doc(volunteerCtx('vol1'), 'DonationReports/rep1'), { status: 'assigned' }),
    );
  });

  it('a non-assigned approved volunteer cannot advance another\'s report', async () => {
    await seed(async (db) => {
      await setDoc(doc(db, 'DonationReports/rep1'), reportData({
        status: 'assigned',
        volunteer_id: 'volX',
      }));
    });
    await seedApprovedVolunteer('vol1');
    await assertFails(
      updateDoc(doc(volunteerCtx('vol1'), 'DonationReports/rep1'), { status: 'collected' }),
    );
  });

  it('rejects mutating an immutable field (quantity) on update', async () => {
    await seed(async (db) => {
      await setDoc(doc(db, 'DonationReports/rep1'), reportData({
        status: 'assigned',
        volunteer_id: 'vol1',
      }));
    });
    await seedApprovedVolunteer('vol1');
    await assertFails(
      updateDoc(doc(volunteerCtx('vol1'), 'DonationReports/rep1'), {
        status: 'collected',
        quantity: 999,
      }),
    );
  });

  it('read: donor(own), assigned volunteer, admin, and approved-volunteer(open) allowed; stranger denied', async () => {
    await seed(async (db) => {
      await setDoc(doc(db, 'DonationReports/rep1'), reportData());
    });
    await seedApprovedVolunteer('vol1');
    await assertSucceeds(getDoc(doc(donorCtx('donor1'), 'DonationReports/rep1')));
    await assertSucceeds(getDoc(doc(adminCtx(), 'DonationReports/rep1')));
    await assertSucceeds(getDoc(doc(volunteerCtx('vol1'), 'DonationReports/rep1')));
    await assertFails(getDoc(doc(donorCtx('donor2'), 'DonationReports/rep1')));
  });

  it('forbids delete (permanent record, FR13)', async () => {
    await seed(async (db) => {
      await setDoc(doc(db, 'DonationReports/rep1'), reportData());
    });
    await assertFails(deleteDoc(doc(donorCtx('donor1'), 'DonationReports/rep1')));
  });

  // --- Phase 4 (FR6/FR7): concurrency-safe accept + decline semantics -------

  it('two volunteers racing to claim the same open report — exactly one wins', async () => {
    await seed(async (db) => {
      await setDoc(doc(db, 'DonationReports/rep1'), reportData());
    });
    await seedApprovedVolunteer('vol1');
    await seedApprovedVolunteer('vol2');

    const [r1, r2] = await Promise.allSettled([
      updateDoc(doc(volunteerCtx('vol1'), 'DonationReports/rep1'), {
        status: 'assigned',
        volunteer_id: 'vol1',
      }),
      updateDoc(doc(volunteerCtx('vol2'), 'DonationReports/rep1'), {
        status: 'assigned',
        volunteer_id: 'vol2',
      }),
    ]);
    const outcomes = [r1.status, r2.status];
    expect(outcomes.filter((s) => s === 'fulfilled')).toHaveLength(1);
    expect(outcomes.filter((s) => s === 'rejected')).toHaveLength(1);

    const finalSnap = await getDoc(doc(adminCtx(), 'DonationReports/rep1'));
    expect(['vol1', 'vol2']).toContain(finalSnap.data()?.volunteer_id);
  });

  // "Decline" (FR7) is a local, client-only dismissal — there is no rule path
  // for it, so any write that leaves status unchanged (i.e. does not perform
  // a real claim) is rejected and the report remains open for another
  // volunteer to accept.
  it('decline leaves the report open — no rule path records a decline', async () => {
    await seed(async (db) => {
      await setDoc(doc(db, 'DonationReports/rep1'), reportData());
    });
    await seedApprovedVolunteer('vol1');
    await assertFails(
      updateDoc(doc(volunteerCtx('vol1'), 'DonationReports/rep1'), {
        declined_by: 'vol1',
      }),
    );

    await seedApprovedVolunteer('vol2');
    await assertSucceeds(
      updateDoc(doc(volunteerCtx('vol2'), 'DonationReports/rep1'), {
        status: 'assigned',
        volunteer_id: 'vol2',
      }),
    );
  });
});

// =============================================================================
// Notifications (Table 4.7) — server-authored
// =============================================================================
describe('Notifications', () => {
  const seedNotif = () =>
    seed(async (db) => {
      await setDoc(doc(db, 'Notifications/n1'), {
        notification_id: 'n1',
        user_id: 'donor1',
        report_id: null,
        message: 'hi',
        type: 'general',
        is_read: false,
        created_at: FIXED_TS,
      });
    });

  it('rejects client create', async () => {
    await assertFails(
      setDoc(doc(donorCtx('donor1'), 'Notifications/n1'), {
        notification_id: 'n1',
        user_id: 'donor1',
        message: 'x',
        type: 'general',
        is_read: false,
        created_at: serverTimestamp(),
      }),
    );
  });

  it('recipient reads own; others cannot', async () => {
    await seedNotif();
    await assertSucceeds(getDoc(doc(donorCtx('donor1'), 'Notifications/n1')));
    await assertFails(getDoc(doc(donorCtx('donor2'), 'Notifications/n1')));
  });

  it('recipient may flip only is_read', async () => {
    await seedNotif();
    await assertSucceeds(
      updateDoc(doc(donorCtx('donor1'), 'Notifications/n1'), { is_read: true }),
    );
    await assertFails(
      updateDoc(doc(donorCtx('donor1'), 'Notifications/n1'), { message: 'tampered' }),
    );
  });

  it('forbids delete', async () => {
    await seedNotif();
    await assertFails(deleteDoc(doc(donorCtx('donor1'), 'Notifications/n1')));
  });

  // Phase 4 (FR6): dispatch alerts written by onDonationReportCreated are
  // ordinary server-authored Notifications docs — readable only by the
  // targeted volunteer, same scoping as any other recipient.
  it('a dispatch alert (new_donation_alert) is readable only by its own volunteer', async () => {
    await seedApprovedVolunteer('vol1');
    await seedApprovedVolunteer('vol2');
    await seed(async (db) => {
      await setDoc(doc(db, 'Notifications/n2'), {
        notification_id: 'n2',
        user_id: 'vol1',
        report_id: 'rep1',
        message: 'بلاغ جديد عن فائض غذائي بالقرب منك.',
        type: 'new_donation_alert',
        is_read: false,
        created_at: FIXED_TS,
      });
    });
    await assertSucceeds(getDoc(doc(volunteerCtx('vol1'), 'Notifications/n2')));
    await assertFails(getDoc(doc(volunteerCtx('vol2'), 'Notifications/n2')));
  });
});

// =============================================================================
// Reports (Table 4.8) — server-computed aggregates
// =============================================================================
describe('Reports', () => {
  const seedReport = (charityId = CHARITY_A) =>
    seed(async (db) => {
      await setDoc(doc(db, 'Reports/agg1'), {
        report_id: 'agg1',
        charity_id: charityId,
        generated_by: 'admin1',
        period_start: FIXED_TS,
        period_end: FIXED_TS,
        total_donations: 3,
        total_quantity: 42,
        generated_at: FIXED_TS,
      });
    });

  it('same-charity admin reads; other-charity admin and non-admin denied', async () => {
    await seedReport(CHARITY_A);
    await seedAdmin('admin1', CHARITY_A);
    await seedAdmin('admin2', CHARITY_B);
    await assertSucceeds(getDoc(doc(adminCtx('admin1'), 'Reports/agg1')));
    await assertFails(getDoc(doc(adminCtx('admin2'), 'Reports/agg1')));
    await assertFails(getDoc(doc(donorCtx('donor1'), 'Reports/agg1')));
  });

  // Regression test (Phase 7 follow-up): the app queries this collection as a
  // LIST (watchGeneratedReports), not a single getDoc. Firestore evaluates
  // list rules differently — it must statically prove the rule holds for
  // EVERY possible result, which requires the query's `where` clause to match
  // the rule's `resource.data.charity_id` condition exactly. A getDoc-only
  // test (above) cannot catch a missing `where` — this was a real bug
  // (reports directory showed "تعذّر تحميل التقارير" in production) that
  // only a genuine list query test exposes.
  it('a charity-filtered list query succeeds for the same-charity admin; '
    + 'an unfiltered list query is rejected outright', async () => {
    await seedReport(CHARITY_A);
    await seedAdmin('admin1', CHARITY_A);

    const filtered = query(
      collection(adminCtx('admin1'), 'Reports'),
      where('charity_id', '==', CHARITY_A),
    );
    await assertSucceeds(getDocs(filtered));

    const unfiltered = collection(adminCtx('admin1'), 'Reports');
    await assertFails(getDocs(unfiltered));
  });

  it('rejects all client writes', async () => {
    await seedAdmin('admin1', CHARITY_A);
    await assertFails(
      setDoc(doc(adminCtx('admin1'), 'Reports/agg2'), {
        report_id: 'agg2',
        charity_id: CHARITY_A,
        total_donations: 1,
      }),
    );
  });
});
