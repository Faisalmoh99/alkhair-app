import 'package:alkhair_app/core/errors/failures.dart';

// Translates every Failure variant into a safe Arabic message (SECURITY.md §7).
// No internal error codes, stack traces, or server messages are shown to the user.
String arabicErrorMessage(Failure failure) => switch (failure) {
      AuthFailure(:final code) => _authMessage(code),
      NetworkFailure() => 'تعذّر الاتصال بالشبكة. يرجى التحقق من الاتصال والمحاولة مجدداً.',
      PermissionFailure() => 'ليس لديك صلاحية لهذا الإجراء.',
      RateLimitFailure() => 'لقد تجاوزت الحد المسموح به. يرجى المحاولة بعد قليل.',
      ValidationFailure(:final field, :final reason) => 'خطأ في الحقل «$field»: $reason',
      ConflictFailure() => 'تم تعيين هذا البلاغ لمتطوع آخر للتو.',
      UnknownFailure() => 'حدث خطأ غير متوقع. يرجى المحاولة مجدداً.',
    };

String _authMessage(String code) => switch (code) {
      'invalid-phone-number' => 'رقم الهاتف غير صحيح. يرجى التحقق والمحاولة مجدداً.',
      'invalid-verification-code' => 'رمز التحقق غير صحيح. يرجى المحاولة مجدداً.',
      'session-expired' => 'انتهت صلاحية رمز التحقق. يرجى طلب رمز جديد.',
      'too-many-requests' => 'طلبات كثيرة جداً. يرجى الانتظار قبل المحاولة مجدداً.',
      'user-disabled' => 'تم تعطيل هذا الحساب. يرجى التواصل مع الدعم.',
      'network-request-failed' => 'تعذّر الاتصال بالشبكة. يرجى التحقق من الاتصال.',
      'notification-not-forwarded' =>
        'تعذر إكمال عملية التحقق حالياً، يرجى المحاولة مرة أخرى بعد قليل.',
      _ => 'فشل التحقق من الهوية. يرجى المحاولة مجدداً.',
    };
