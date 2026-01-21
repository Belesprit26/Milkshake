import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/result/result.dart';
import '../../../di/locator.dart';
import '../../../domain/auth/repositories/auth_repository.dart';
import '../../../domain/orders/entities/order_list_item.dart';
import '../../../domain/orders/repositories/order_repository.dart';

part 'order_history_event.dart';
part 'order_history_state.dart';

class OrderHistoryBloc extends Bloc<OrderHistoryEvent, OrderHistoryState> {
  OrderHistoryBloc({
    OrderRepository? orders,
    AuthRepository? auth,
  })  : _orders = orders ?? getIt<OrderRepository>(),
        _auth = auth ?? getIt<AuthRepository>(),
        super(const OrderHistoryState.initial()) {
    on<OrderHistoryStarted>(_onStarted);
    on<OrderHistoryRefreshRequested>(_onRefresh);
  }

  final OrderRepository _orders;
  final AuthRepository _auth;

  Future<void> _onStarted(OrderHistoryStarted event, Emitter<OrderHistoryState> emit) async {
    await _load(emit);
  }

  Future<void> _onRefresh(OrderHistoryRefreshRequested event, Emitter<OrderHistoryState> emit) async {
    await _load(emit);
  }

  Future<void> _load(Emitter<OrderHistoryState> emit) async {
    emit(state.copyWith(status: OrderHistoryStatus.loading, error: null));
    final user = _auth.currentUser();
    if (user == null) {
      emit(state.copyWith(status: OrderHistoryStatus.failure, error: 'Not signed in.'));
      return;
    }

    final res = await _orders.listForUser(user.uid);
    switch (res) {
      case Err(failure: final f):
        emit(state.copyWith(status: OrderHistoryStatus.failure, error: f.message));
      case Ok(value: final items):
        emit(state.copyWith(status: OrderHistoryStatus.ready, items: items));
    }
  }
}


