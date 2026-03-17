import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignupUseCase {
  final AuthRepository repository;

  SignupUseCase(this.repository);

  Future<AppUser> call({
    required String email,
    required String password,
    String? displayName,
  }) {
    return repository.signup(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}
