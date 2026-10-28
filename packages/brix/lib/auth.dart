/// Brix auth block: backend-agnostic login, signup, OTP, password reset.
///
/// Also exports the core block ([Result], [Failure]) it is built on.
library;

export 'core.dart';
export 'src/auth/auth_capabilities.dart';
export 'src/auth/auth_feedback.dart';
export 'src/auth/auth_form_flow.dart';
export 'src/auth/auth_navigator.dart';
export 'src/auth/auth_provider.dart';
export 'src/auth/auth_session.dart';
export 'src/auth/auth_session_store.dart';
export 'src/auth/auth_warning.dart';
export 'src/auth/code_entry_flow.dart';
export 'src/auth/forgot_password_flow.dart';
export 'src/auth/identifier_mask.dart';
export 'src/auth/login_flow.dart';
export 'src/auth/otp_purpose.dart';
export 'src/auth/otp_verification_flow.dart';
export 'src/auth/password_policy.dart';
export 'src/auth/remembered_credentials.dart';
export 'src/auth/reset_password_flow.dart';
export 'src/auth/signup_flow.dart';
