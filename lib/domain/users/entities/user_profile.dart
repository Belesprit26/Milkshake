import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.uid,
    required this.firstName,
    required this.mobile,
    required this.email,
  });

  final String uid;
  final String firstName;
  final String mobile;
  final String email;

  @override
  List<Object?> get props => [uid, firstName, mobile, email];
}


