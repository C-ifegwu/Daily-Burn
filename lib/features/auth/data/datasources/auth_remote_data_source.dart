import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
  final FirebaseAuth? _firebaseAuthOverride;
  final FirebaseFirestore? _firestoreOverride;
  final GoogleSignIn? _googleSignInOverride;
  GoogleSignIn? _googleSignInInstance;

  FirebaseAuth get _firebaseAuth =>
      _firebaseAuthOverride ?? FirebaseAuth.instance;
  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;
  GoogleSignIn get _googleSignIn {
    if (_googleSignInOverride != null) {
      return _googleSignInOverride!;
    }
    _googleSignInInstance ??= _createGoogleSignIn();
    return _googleSignInInstance!;
  }

  FirebaseAuthRemoteDataSource({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuthOverride = firebaseAuth,
        _firestoreOverride = firestore,
        _googleSignInOverride = googleSignIn;

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    _ensureFirebaseInitialized();
    try {
      final UserCredential credential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = credential.user;
      if (user == null) {
        throw StateError('Unable to authenticate user.');
      }

      await _upsertUserDocument(user);

      return _toUserJson(user);
    } catch (error) {
      throw Exception(_normalizeAuthError(error));
    }
  }

  @override
  Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _ensureFirebaseInitialized();
    try {
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
      await _upsertUserDocument(latestUser);
      return _toUserJson(latestUser);
    } catch (error) {
      throw Exception(_normalizeAuthError(error));
    }
  }

  @override
  Future<Map<String, dynamic>> signInWithGoogle() async {
    _ensureFirebaseInitialized();
    try {
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

      await _upsertUserDocument(user);

      return _toUserJson(user);
    } catch (error) {
      if (error is AuthCancelledException) {
        rethrow;
      }
      throw Exception(_normalizeAuthError(error));
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    if (_googleSignInOverride != null || _googleSignInInstance != null) {
      await _googleSignIn.signOut();
    }
  }

  Map<String, dynamic> _toUserJson(User user) {
    return <String, dynamic>{
      'id': user.uid,
      'email': user.email ?? '',
      'displayName': user.displayName,
    };
  }

  Future<void> _upsertUserDocument(User user) async {
    try {
      await user.getIdToken(true);
      await _firestore.collection('users').doc(user.uid).set(
        <String, dynamic>{
          'uid': user.uid,
          'userId': user.uid,
          'email': user.email ?? '',
          'displayName': user.displayName ?? '',
          'photoUrl': user.photoURL,
          'lastLoginAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (error) {
      debugPrint(
        'Failed to upsert Firestore user profile: $error. Check Firestore rules for users/{uid}.',
      );
    }
  }

  GoogleSignIn _createGoogleSignIn() {
    if (!kIsWeb) {
      return GoogleSignIn();
    }

    const String webClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
    if (webClientId.isEmpty) {
      throw StateError(
        'Google Sign-In is not configured for web. Start with --dart-define=GOOGLE_WEB_CLIENT_ID=<your web client id> or add the google-signin client meta tag in web/index.html.',
      );
    }
    return GoogleSignIn(clientId: webClientId);
  }

  void _ensureFirebaseInitialized() {
    if (Firebase.apps.isEmpty) {
      throw StateError(
        'Firebase is not initialized. Configure Firebase for this app and restart.',
      );
    }
  }

  String _normalizeAuthError(Object error) {
    if (error is FirebaseAuthException) {
      return error.message ?? error.code;
    }
    if (error is FirebaseException) {
      return error.message ?? error.code;
    }

    final String raw = error.toString();
    if (raw.contains('Google Sign-In is not configured for web')) {
      return 'Google Sign-In is not configured for web. Add GOOGLE_WEB_CLIENT_ID and restart the app.';
    }
    if (raw.contains('JavaScriptObject') && raw.contains('FirebaseException')) {
      return 'Firebase web configuration is invalid or incomplete. Run FlutterFire setup and restart the app.';
    }
    return raw.replaceFirst('Exception: ', '');
  }
}
