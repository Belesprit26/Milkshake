part of 'confirm_order_bloc.dart';

sealed class ConfirmOrderEvent extends Equatable {
  const ConfirmOrderEvent();
  @override
  List<Object?> get props => [];
}

final class ConfirmOrderStarted extends ConfirmOrderEvent {
  const ConfirmOrderStarted(this.orderId);
  final String orderId;
  @override
  List<Object?> get props => [orderId];
}

final class ConfirmOrderPressed extends ConfirmOrderEvent {
  const ConfirmOrderPressed();
}

final class ConfirmOrderPayPressed extends ConfirmOrderEvent {
  const ConfirmOrderPayPressed();
}


