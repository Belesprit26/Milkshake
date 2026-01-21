part of 'sign_up_bloc.dart';

sealed class SignUpEvent extends Equatable {
  const SignUpEvent();
  @override
  List<Object?> get props => [];
}

final class SignUpEmailChanged extends SignUpEvent {
  const SignUpEmailChanged(this.email);
  final String email;
  @override
  List<Object?> get props => [email];
}

final class SignUpPasswordChanged extends SignUpEvent {
  const SignUpPasswordChanged(this.password);
  final String password;
  @override
  List<Object?> get props => [password];
}

final class SignUpFirstNameChanged extends SignUpEvent {
  const SignUpFirstNameChanged(this.firstName);
  final String firstName;
  @override
  List<Object?> get props => [firstName];
}

final class SignUpMobileChanged extends SignUpEvent {
  const SignUpMobileChanged(this.mobile);
  final String mobile;
  @override
  List<Object?> get props => [mobile];
}

final class SignUpSubmitted extends SignUpEvent {
  const SignUpSubmitted();
}


