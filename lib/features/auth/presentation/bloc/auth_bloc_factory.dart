import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/google_signin_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import 'auth_bloc.dart';

AuthBloc createAuthBloc() {
  final dataSource = FirebaseAuthRemoteDataSource();
  final repository = AuthRepositoryImpl(remoteDataSource: dataSource);

  return AuthBloc(
    loginUseCase: LoginUseCase(repository),
    signupUseCase: SignupUseCase(repository),
    googleSignInUseCase: GoogleSignInUseCase(repository),
    logoutUseCase: LogoutUseCase(repository),
  );
}