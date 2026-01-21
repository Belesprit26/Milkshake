import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../di/locator.dart';
import '../../../domain/auth/entities/auth_user.dart';
import '../../../domain/auth/repositories/auth_repository.dart';

part 'auth_gate_state.dart';

class AuthGateCubit extends Cubit<AuthGateState> {
  AuthGateCubit({AuthRepository? authRepository})
      : _authRepository = authRepository ?? getIt<AuthRepository>(),
        super(const AuthGateState.loading()) {
    _sub = _authRepository.authStateChanges().listen((user) {
      emit(AuthGateState.ready(user: user));
    });
  }

  final AuthRepository _authRepository;
  late final StreamSubscription<AuthUser?> _sub;

  @override
  Future<void> close() async {
    await _sub.cancel();
    return super.close();
  }
}


