import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/error/failure.dart';
import '../../../core/result/result.dart';
import '../../../domain/users/entities/user_profile.dart';
import '../../../domain/users/repositories/user_profile_repository.dart';

class FirestoreUserProfileRepository implements UserProfileRepository {
  FirestoreUserProfileRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<Result<void>> upsertProfile(UserProfile profile) async {
    try {
      final ref = _firestore.collection('users').doc(profile.uid);
      await _firestore.runTransaction((tx) async {
        final snap = await tx.get(ref);
        final base = <String, Object?>{
          'firstName': profile.firstName,
          'mobile': profile.mobile,
          'email': profile.email,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (!snap.exists) {
          tx.set(ref, {...base, 'createdAt': FieldValue.serverTimestamp()});
        } else {
          tx.set(ref, base, SetOptions(merge: true));
        }
      });
      return const Ok(null);
    } catch (e) {
      return Err(UnexpectedFailure('Failed to upsert user profile: $e'));
    }
  }
}


