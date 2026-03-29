import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> login({required String email, required String password});

  Future<AppUser> signup({
    required String email,
    required String password,
    String? displayName,
  });

  Future<AppUser> googleSignIn();

  Future<void> logout();
}
