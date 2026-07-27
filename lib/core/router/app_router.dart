import 'package:alkhair_app/core/router/auth_guard.dart';
import 'package:alkhair_app/features/auth/domain/entities/auth_stage.dart';
import 'package:alkhair_app/features/auth/presentation/controllers/auth_status_controller.dart';
import 'package:alkhair_app/features/auth/presentation/screens/account_type_screen.dart';
import 'package:alkhair_app/features/auth/presentation/screens/otp_screen.dart';
import 'package:alkhair_app/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:alkhair_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:alkhair_app/features/auth/presentation/screens/volunteer_extra_step_screen.dart';
import 'package:alkhair_app/features/charity_admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:alkhair_app/features/charity_admin/presentation/screens/category_detail_screen.dart';
import 'package:alkhair_app/features/charity_admin/presentation/screens/monthly_summary_screen.dart';
import 'package:alkhair_app/features/charity_admin/presentation/screens/report_export_screen.dart';
import 'package:alkhair_app/features/charity_admin/presentation/screens/reports_directory_screen.dart';
import 'package:alkhair_app/features/charity_admin/presentation/screens/volunteer_approval_screen.dart';
import 'package:alkhair_app/features/charity_admin/presentation/screens/volunteer_performance_screen.dart';
import 'package:alkhair_app/features/donor/presentation/screens/donor_home_screen.dart';
import 'package:alkhair_app/features/donor/presentation/screens/donor_report_screen.dart';
import 'package:alkhair_app/features/donor/presentation/screens/donor_status_screen.dart';
import 'package:alkhair_app/features/volunteer/presentation/screens/volunteer_alert_screen.dart';
import 'package:alkhair_app/features/volunteer/presentation/screens/volunteer_home_screen.dart';
import 'package:alkhair_app/features/volunteer/presentation/screens/volunteer_nav_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// Route paths. Auth sub-routes live under `/sign-in`; each role has its own
/// area prefix (`/donor`, `/volunteer`, `/admin`) enforced by [authRedirect].
abstract final class Routes {
  static const String splash = '/';
  // Auth (Phase 2)
  static const String signIn = '/sign-in';
  static const String otp = '/sign-in/otp';
  static const String accountType = '/sign-in/account-type';
  static const String volunteerExtra = '/sign-in/volunteer-details';
  // Role landings
  static const String donorHome = '/donor/home';
  static const String volunteerHome = '/volunteer/home';
  static const String adminDashboard = '/admin/dashboard';
  // Donor (Phase 3)
  static const String donorReport = '/donor/report';
  static const String donorStatus = '/donor/status';
  // Volunteer (Phase 4)
  static const String volunteerAlert = '/volunteer/alert';
  static const String volunteerNav = '/volunteer/navigate';
  // Admin (Phase 5)
  static const String adminVolunteers = '/admin/volunteers';
  // Reports (Phase 6)
  static const String reportsDirectory = '/admin/reports';
  static const String reportMonthly = '/admin/reports/monthly';
  static const String reportCategory = '/admin/reports/category';
  static const String reportPerformance = '/admin/reports/performance';
  static const String reportExport = '/admin/reports/export';
}

/// The app router. Redirects are driven by [authStatusControllerProvider]: the
/// stage is bridged into a [ValueNotifier] that GoRouter listens to, so the
/// router is created once and re-evaluates guards whenever the stage changes.
@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  final refresh = ValueNotifier<AsyncValue<AuthStage>>(const AsyncLoading());
  ref
    ..onDispose(refresh.dispose)
    ..listen(
      authStatusControllerProvider,
      (_, next) => refresh.value = next,
      fireImmediately: true,
    );

  return GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      // While the stage is still resolving, hold on the splash screen.
      return refresh.value.maybeWhen(
        data: (stage) =>
            authRedirect(stage: stage, location: state.matchedLocation),
        orElse: () => null,
      );
    },
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.signIn,
        builder: (_, __) => const SignInScreen(),
      ),
      GoRoute(
        path: Routes.otp,
        builder: (_, __) => const OtpScreen(),
      ),
      GoRoute(
        path: Routes.accountType,
        builder: (_, __) => const AccountTypeScreen(),
      ),
      GoRoute(
        path: Routes.volunteerExtra,
        builder: (_, __) => const VolunteerExtraStepScreen(),
      ),
      GoRoute(
        path: Routes.donorHome,
        builder: (_, __) => const DonorHomeScreen(),
      ),
      GoRoute(
        path: Routes.donorReport,
        builder: (_, __) => const DonorReportScreen(),
      ),
      GoRoute(
        path: Routes.donorStatus,
        builder: (_, __) => const DonorStatusScreen(),
      ),
      GoRoute(
        path: Routes.volunteerHome,
        builder: (_, __) => const VolunteerHomeScreen(),
      ),
      GoRoute(
        path: Routes.volunteerAlert,
        builder: (_, __) => const VolunteerAlertScreen(),
      ),
      GoRoute(
        path: Routes.volunteerNav,
        builder: (_, state) {
          final reportId = state.extra as String?;
          if (reportId == null) {
            return const Scaffold(
              body: Center(child: Text('لم يتم تحديد البلاغ.')),
            );
          }
          return VolunteerNavScreen(reportId: reportId);
        },
      ),
      GoRoute(
        path: Routes.adminDashboard,
        builder: (_, __) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: Routes.adminVolunteers,
        builder: (_, __) => const VolunteerApprovalScreen(),
      ),
      GoRoute(
        path: Routes.reportsDirectory,
        builder: (_, __) => const ReportsDirectoryScreen(),
      ),
      GoRoute(
        path: Routes.reportMonthly,
        builder: (_, __) => const MonthlySummaryScreen(),
      ),
      GoRoute(
        path: Routes.reportCategory,
        builder: (_, __) => const CategoryDetailScreen(),
      ),
      GoRoute(
        path: Routes.reportPerformance,
        builder: (_, __) => const VolunteerPerformanceScreen(),
      ),
      GoRoute(
        path: Routes.reportExport,
        builder: (_, __) => const ReportExportScreen(),
      ),
    ],
  );
}
