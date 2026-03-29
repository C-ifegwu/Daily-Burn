import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AppUser> login(
      {required String email, required String password}) async {
    final Map<String, dynamic> json = await remoteDataSource.login(
      email: email,
      password: password,
    );
    return UserModel.fromJson(json);
  }

  @override
  Future<AppUser> signup({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final Map<String, dynamic> json = await remoteDataSource.signup(
      email: email,
      password: password,
      displayName: displayName,
    );
    return UserModel.fromJson(json);
  }

  @override
  Future<AppUser> googleSignIn() async {
    final Map<String, dynamic> json = await remoteDataSource.signInWithGoogle();
    return UserModel.fromJson(json);
  }

  @override
  Future<void> logout() {
    return remoteDataSource.logout();
  }
}
