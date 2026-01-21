part of 'confirm_order_bloc.dart';

enum ConfirmOrderStatus { initial, loading, ready, submitting, success, failure }

class ConfirmOrderState extends Equatable {
  const ConfirmOrderState({
    required this.status,
    required this.order,
    required this.error,
    required this.checkoutUrl,
  });

  const ConfirmOrderState.initial()
      : status = ConfirmOrderStatus.initial,
        order = null,
        error = null,
        checkoutUrl = null;

  final ConfirmOrderStatus status;
  final OrderDraft? order;
  final String? error;
  final String? checkoutUrl;

  ConfirmOrderState copyWith({
    ConfirmOrderStatus? status,
    OrderDraft? order,
    String? error,
    String? checkoutUrl,
  }) {
    return ConfirmOrderState(
      status: status ?? this.status,
      order: order ?? this.order,
      error: error,
      checkoutUrl: checkoutUrl ?? this.checkoutUrl,
    );
  }

  @override
  List<Object?> get props => [status, order, error, checkoutUrl];
}


