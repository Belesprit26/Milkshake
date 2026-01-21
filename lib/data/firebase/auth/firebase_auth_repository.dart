import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/error/failure.dart';
import '../../../core/result/result.dart';
import '../../../domain/auth/entities/auth_user.dart';
import '../../../domain/auth/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({required FirebaseAuth auth}) : _auth = auth;

  final FirebaseAuth _auth;

  @override
  Stream<AuthUser?> authStateChanges() {
    return _auth.authStateChanges().map(_mapUser);
  }

  @override
  AuthUser? currentUser() => _mapUser(_auth.currentUser);

  @override
  Future<Result<AuthUser>> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final normalizedEmail = _normalizeEmail(email);
      final cred = await _auth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
      final user = _mapUser(cred.user);
      if (user == null) return Err(const UnexpectedFailure('No user returned from sign in.'));
      return Ok(user);
    } on FirebaseAuthException catch (e) {
      return Err(ValidationFailure(e.message ?? e.code));
    } catch (e) {
      return Err(UnexpectedFailure('Sign in failed: $e'));
    }
  }

  @override
  Future<Result<AuthUser>> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final normalizedEmail = _normalizeEmail(email);
      final cred = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
      final user = _mapUser(cred.user);
      if (user == null) return Err(const UnexpectedFailure('No user returned from sign up.'));
      return Ok(user);
    } on FirebaseAuthException catch (e) {
      return Err(ValidationFailure(e.message ?? e.code));
    } catch (e) {
      return Err(UnexpectedFailure('Sign up failed: $e'));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
      return const Ok(null);
    } catch (e) {
      return Err(UnexpectedFailure('Sign out failed: $e'));
    }
  }

  AuthUser? _mapUser(User? u) {
    final email = u?.email;
    if (u == null || email == null) return null;
    return AuthUser(uid: u.uid, email: email);
  }

  String _normalizeEmail(String email) {
    return email.replaceAll(RegExp(r'\s+'), '').trim().toLowerCase();
  }
}


