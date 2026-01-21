part of 'order_history_bloc.dart';

enum OrderHistoryStatus { initial, loading, ready, failure }

class OrderHistoryState extends Equatable {
  const OrderHistoryState({
    required this.status,
    required this.items,
    required this.error,
  });

  const OrderHistoryState.initial()
      : status = OrderHistoryStatus.initial,
        items = const [],
        error = null;

  final OrderHistoryStatus status;
  final List<OrderListItem> items;
  final String? error;

  OrderHistoryState copyWith({
    OrderHistoryStatus? status,
    List<OrderListItem>? items,
    String? error,
  }) {
    return OrderHistoryState(
      status: status ?? this.status,
      items: items ?? this.items,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, items, error];
}


