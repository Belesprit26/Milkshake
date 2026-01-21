import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/result/result.dart';
import '../../../di/locator.dart';
import '../../../domain/auth/usecases/sign_up_with_email_password.dart';
import '../../../domain/users/entities/user_profile.dart';
import '../../../domain/users/usecases/upsert_user_profile.dart';

part 'sign_up_event.dart';
part 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  SignUpBloc({
    SignUpWithEmailPassword? signUp,
    UpsertUserProfile? upsertProfile,
  })  : _signUp = signUp ?? getIt<SignUpWithEmailPassword>(),
        _upsertProfile = upsertProfile ?? getIt<UpsertUserProfile>(),
        super(const SignUpState()) {
    on<SignUpEmailChanged>((e, emit) => emit(state.copyWith(email: e.email)));
    on<SignUpPasswordChanged>((e, emit) => emit(state.copyWith(password: e.password)));
    on<SignUpFirstNameChanged>((e, emit) => emit(state.copyWith(firstName: e.firstName)));
    on<SignUpMobileChanged>((e, emit) => emit(state.copyWith(mobile: e.mobile)));
    on<SignUpSubmitted>(_onSubmit);
  }

  final SignUpWithEmailPassword _signUp;
  final UpsertUserProfile _upsertProfile;

  Future<void> _onSubmit(SignUpSubmitted event, Emitter<SignUpState> emit) async {
    emit(state.copyWith(status: SignUpStatus.submitting, error: null));

    final signUpRes = await _signUp(email: state.email, password: state.password);
    late final user;
    switch (signUpRes) {
      case Err(failure: final f):
        emit(state.copyWith(status: SignUpStatus.failure, error: f.message));
        return;
      case Ok(value: final u):
        user = u;
    }

    final profile = UserProfile(
      uid: user.uid,
      firstName: state.firstName,
      mobile: state.mobile,
      email: user.email,
    );

    final profileRes = await _upsertProfile(profile);
    switch (profileRes) {
      case Err(failure: final f):
        emit(state.copyWith(status: SignUpStatus.failure, error: f.message));
        return;
      case Ok():
        break;
    }

    emit(state.copyWith(status: SignUpStatus.success));
  }
}


