import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/usecases/google_signin_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc {
  final LoginUseCase _loginUseCase;
  final SignupUseCase _signupUseCase;
  final GoogleSignInUseCase _googleSignInUseCase;
  final LogoutUseCase _logoutUseCase;

  final StreamController<AuthEvent> _eventController =
      StreamController<AuthEvent>();
  final StreamController<AuthState> _stateController =
      StreamController<AuthState>.broadcast();

  AuthState _state = const AuthInitial();

  AuthBloc({
    required LoginUseCase loginUseCase,
    required SignupUseCase signupUseCase,
    required GoogleSignInUseCase googleSignInUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _loginUseCase = loginUseCase,
        _signupUseCase = signupUseCase,
        _googleSignInUseCase = googleSignInUseCase,
        _logoutUseCase = logoutUseCase {
    _eventController.stream.listen((AuthEvent event) {
      _handleEvent(event);
    });
  }

  Stream<AuthState> get stream => _stateController.stream;

  AuthState get state => _state;

  void add(AuthEvent event) {
    if (!_eventController.isClosed) {
      _eventController.add(event);
    }
  }

  Future<void> _handleEvent(AuthEvent event) async {
    if (event is LoginRequested) {
      await _login(event);
      return;
    }
    if (event is SignupRequested) {
      await _signup(event);
      return;
    }
    if (event is GoogleSigninRequested) {
      await _googleSignIn();
      return;
    }
    if (event is LogoutRequested) {
      await _logout();
    }
  }

  Future<void> _login(LoginRequested event) async {
    _emit(const AuthLoading());
    try {
      final user = await _loginUseCase(
        email: event.email,
        password: event.password,
      );
      _emit(AuthAuthenticated(user));
    } catch (error) {
      _emit(AuthFailure(_mapError(error)));
    }
  }

  Future<void> _signup(SignupRequested event) async {
    _emit(const AuthLoading());
    try {
      final user = await _signupUseCase(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      );
      _emit(AuthAuthenticated(user));
    } catch (error) {
      _emit(AuthFailure(_mapError(error)));
    }
  }

  Future<void> _googleSignIn() async {
    _emit(const AuthLoading());
    try {
      final user = await _googleSignInUseCase();
      _emit(AuthAuthenticated(user));
    } catch (error) {
      _emit(AuthFailure(_mapError(error)));
    }
  }

  Future<void> _logout() async {
    _emit(const AuthLoading());
    try {
      await _logoutUseCase();
      _emit(const AuthUnauthenticated());
    } catch (error) {
      _emit(AuthFailure(_mapError(error)));
    }
  }

  void _emit(AuthState state) {
    _state = state;
    if (!_stateController.isClosed) {
      _stateController.add(state);
    }
  }

  String _mapError(Object error) {
    // Handle FirebaseAuthException specifically
    if (error is FirebaseAuthException) {
      final String code = error.code;

      switch (code) {
        case 'user-not-found':
          return 'No account found with that email.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'email-already-in-use':
          return 'This email is already in use.';
        case 'weak-password':
          return 'Password is too weak.';
        case 'invalid-email':
          return 'Invalid email address.';
        case 'operation-not-allowed':
          return 'This operation is not allowed.';
        case 'too-many-requests':
          return 'Too many login attempts. Please try again later.';
        default:
          return error.message ?? 'An authentication error occurred.';
      }
    }

    // Handle FirebaseException
    if (error is FirebaseException) {
      return error.message ?? 'A Firebase error occurred.';
    }

    // Handle custom cancellation
    if (error.toString().contains('Authentication was cancelled')) {
      return 'Google sign in was cancelled.';
    }

    // Fallback to string conversion
    final String message = error.toString();
    return message.replaceFirst('Exception: ', '');
  }

  Future<void> close() async {
    await _eventController.close();
    await _stateController.close();
  }
}
