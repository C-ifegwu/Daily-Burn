import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class GoogleSignInUseCase {
  final AuthRepository repository;

  GoogleSignInUseCase(this.repository);

  Future<AppUser> call() {
    return repository.googleSignIn();
  }
}
