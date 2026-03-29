import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Contract for remote auth operations.
abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  });

  Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    String? displayName,
  });

  Future<Map<String, dynamic>> signInWithGoogle();

  Future<void> logout();
}

class AuthCancelledException implements Exception {
  final String message;

  const AuthCancelledException(
      [this.message = 'Authentication was cancelled.']);

  @override
  String toString() => message;
}

class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthRemoteDataSource({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final UserCredential credential =
        await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final User? user = credential.user;
    if (user == null) {
      throw StateError('Unable to authenticate user.');
    }

    return _toUserJson(user);
  }

  @override
  Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final UserCredential credential =
        await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final User? createdUser = credential.user;
    if (createdUser == null) {
      throw StateError('Unable to create user.');
    }

    final String? safeDisplayName = displayName?.trim();
    if (safeDisplayName != null && safeDisplayName.isNotEmpty) {
      await createdUser.updateDisplayName(safeDisplayName);
      await createdUser.reload();
    }

    final User latestUser = _firebaseAuth.currentUser ?? createdUser;
    return _toUserJson(latestUser);
  }

  @override
  Future<Map<String, dynamic>> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw const AuthCancelledException();
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );

    final UserCredential userCredential =
        await _firebaseAuth.signInWithCredential(credential);

    final User? user = userCredential.user;
    if (user == null) {
      throw StateError('Unable to authenticate Google user.');
    }

    return _toUserJson(user);
  }

  @override
  Future<void> logout() async {
    await Future.wait(<Future<void>>[
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Map<String, dynamic> _toUserJson(User user) {
    return <String, dynamic>{
      'id': user.uid,
      'email': user.email ?? '',
      'displayName': user.displayName,
    };
  }
}
