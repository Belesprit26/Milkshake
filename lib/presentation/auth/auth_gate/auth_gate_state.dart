part of 'auth_gate_cubit.dart';

class AuthGateState extends Equatable {
  const AuthGateState._({required this.isLoading, required this.user});

  const AuthGateState.loading() : this._(isLoading: true, user: null);

  const AuthGateState.ready({required AuthUser? user})
      : this._(isLoading: false, user: user);

  final bool isLoading;
  final AuthUser? user;

  bool get isAuthed => user != null;

  @override
  List<Object?> get props => [isLoading, user];
}


