sealed class AuthEvent {
  const AuthEvent();
}

final class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});
}

final class SignupRequested extends AuthEvent {
  final String email;
  final String password;
  final String? displayName;

  const SignupRequested({
    required this.email,
    required this.password,
    this.displayName,
  });
}

final class GoogleSigninRequested extends AuthEvent {
  const GoogleSigninRequested();
}

final class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
