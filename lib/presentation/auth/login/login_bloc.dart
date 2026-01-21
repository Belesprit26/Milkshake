import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../di/locator.dart';
import '../../../domain/auth/usecases/sign_in_with_email_password.dart';
import '../../../core/result/result.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({SignInWithEmailPassword? signIn})
      : _signIn = signIn ?? getIt<SignInWithEmailPassword>(),
        super(const LoginState()) {
    on<LoginEmailChanged>((e, emit) => emit(state.copyWith(email: e.email)));
    on<LoginPasswordChanged>((e, emit) => emit(state.copyWith(password: e.password)));
    on<LoginSubmitted>(_onSubmit);
  }

  final SignInWithEmailPassword _signIn;

  Future<void> _onSubmit(LoginSubmitted event, Emitter<LoginState> emit) async {
    emit(state.copyWith(status: LoginStatus.submitting, error: null));
    final res = await _signIn(email: state.email, password: state.password);
    switch (res) {
      case Err(failure: final f):
        emit(state.copyWith(status: LoginStatus.failure, error: f.message));
      case Ok():
        emit(state.copyWith(status: LoginStatus.success));
    }
  }
}


