part of 'sign_up_bloc.dart';

enum SignUpStatus { idle, submitting, success, failure }

class SignUpState extends Equatable {
  const SignUpState({
    this.email = '',
    this.password = '',
    this.firstName = '',
    this.mobile = '',
    this.status = SignUpStatus.idle,
    this.error,
  });

  final String email;
  final String password;
  final String firstName;
  final String mobile;
  final SignUpStatus status;
  final String? error;

  SignUpState copyWith({
    String? email,
    String? password,
    String? firstName,
    String? mobile,
    SignUpStatus? status,
    String? error,
  }) {
    return SignUpState(
      email: email ?? this.email,
      password: password ?? this.password,
      firstName: firstName ?? this.firstName,
      mobile: mobile ?? this.mobile,
      status: status ?? this.status,
      error: error,
    );
  }

  @override
  List<Object?> get props => [email, password, firstName, mobile, status, error];
}


