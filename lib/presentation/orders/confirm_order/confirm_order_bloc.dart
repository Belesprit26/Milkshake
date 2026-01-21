import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/result/result.dart';
import '../../../di/locator.dart';
import '../../../domain/orders/entities/order_draft.dart';
import '../../../domain/orders/entities/order_status.dart';
import '../../../domain/orders/repositories/order_repository.dart';
import '../../../domain/payments/repositories/payment_repository.dart';

part 'confirm_order_event.dart';
part 'confirm_order_state.dart';

class ConfirmOrderBloc extends Bloc<ConfirmOrderEvent, ConfirmOrderState> {
  ConfirmOrderBloc({OrderRepository? orders, PaymentRepository? payments})
      : _orders = orders ?? getIt<OrderRepository>(),
        _payments = payments ?? getIt<PaymentRepository>(),
        super(const ConfirmOrderState.initial()) {
    on<ConfirmOrderStarted>(_onStarted);
    on<ConfirmOrderPressed>(_onConfirmPressed);
    on<ConfirmOrderPayPressed>(_onPayPressed);
  }

  final OrderRepository _orders;
  final PaymentRepository _payments;

  Future<void> _onStarted(ConfirmOrderStarted event, Emitter<ConfirmOrderState> emit) async {
    emit(state.copyWith(status: ConfirmOrderStatus.loading));
    final res = await _orders.getById(event.orderId);
    switch (res) {
      case Err(failure: final f):
        emit(state.copyWith(status: ConfirmOrderStatus.failure, error: f.message));
      case Ok(value: final order):
        emit(state.copyWith(status: ConfirmOrderStatus.ready, order: order));
    }
  }

  Future<void> _onConfirmPressed(
    ConfirmOrderPressed event,
    Emitter<ConfirmOrderState> emit,
  ) async {
    final order = state.order;
    if (order == null) return;
    emit(state.copyWith(status: ConfirmOrderStatus.submitting, error: null));

    final res = await _orders.setStatus(orderId: order.id!, status: OrderStatus.pendingPayment);
    switch (res) {
      case Err(failure: final f):
        emit(state.copyWith(status: ConfirmOrderStatus.failure, error: f.message));
      case Ok():
        // Reload the order to reflect status change.
        add(ConfirmOrderStarted(order.id!));
    }
  }

  Future<void> _onPayPressed(
    ConfirmOrderPayPressed event,
    Emitter<ConfirmOrderState> emit,
  ) async {
    final order = state.order;
    if (order?.id == null) return;
    emit(state.copyWith(status: ConfirmOrderStatus.submitting, error: null));
    final res = await _payments.createCheckoutUrl(orderId: order!.id!);
    switch (res) {
      case Err(failure: final f):
        emit(state.copyWith(status: ConfirmOrderStatus.failure, error: f.message));
      case Ok(value: final url):
        emit(state.copyWith(status: ConfirmOrderStatus.ready, checkoutUrl: url));
    }
  }
}


