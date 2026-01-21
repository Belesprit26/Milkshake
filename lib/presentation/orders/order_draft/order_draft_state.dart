part of 'order_draft_bloc.dart';

enum OrderDraftStatus { initial, loading, ready, failure }

class OrderDraftState extends Equatable {
  const OrderDraftState({
    required this.status,
    required this.drinkCount,
    required this.flavours,
    required this.toppings,
    required this.consistencies,
    required this.stores,
    required this.drinks,
    required this.totals,
    required this.config,
    required this.pickupStore,
    required this.pickupTime,
    required this.isSaving,
    required this.orderId,
    required this.message,
  });

  const OrderDraftState.initial()
      : status = OrderDraftStatus.initial,
        drinkCount = 1,
        flavours = const [],
        toppings = const [],
        consistencies = const [],
        stores = const [],
        drinks = const [],
        totals = null,
        config = null,
        pickupStore = null,
        pickupTime = null,
        isSaving = false,
        orderId = null,
        message = null;

  final OrderDraftStatus status;
  final int drinkCount;
  final List<LookupItemSnapshot> flavours;
  final List<LookupItemSnapshot> toppings;
  final List<LookupItemSnapshot> consistencies;
  final List<LookupItemSnapshot> stores;
  final List<DrinkItem> drinks;
  final OrderTotals? totals;
  final ConfigSnapshot? config;
  final LookupItemSnapshot? pickupStore;
  final String? pickupTime;
  final bool isSaving;
  final String? orderId;
  final String? message;

  OrderDraftState copyWith({
    OrderDraftStatus? status,
    int? drinkCount,
    List<LookupItemSnapshot>? flavours,
    List<LookupItemSnapshot>? toppings,
    List<LookupItemSnapshot>? consistencies,
    List<LookupItemSnapshot>? stores,
    List<DrinkItem>? drinks,
    OrderTotals? totals,
    ConfigSnapshot? config,
    LookupItemSnapshot? pickupStore,
    String? pickupTime,
    bool? isSaving,
    String? orderId,
    String? message,
  }) {
    return OrderDraftState(
      status: status ?? this.status,
      drinkCount: drinkCount ?? this.drinkCount,
      flavours: flavours ?? this.flavours,
      toppings: toppings ?? this.toppings,
      consistencies: consistencies ?? this.consistencies,
      stores: stores ?? this.stores,
      drinks: drinks ?? this.drinks,
      totals: totals ?? this.totals,
      config: config ?? this.config,
      pickupStore: pickupStore ?? this.pickupStore,
      pickupTime: pickupTime ?? this.pickupTime,
      isSaving: isSaving ?? this.isSaving,
      orderId: orderId ?? this.orderId,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
        status,
        drinkCount,
        flavours,
        toppings,
        consistencies,
        stores,
        drinks,
        totals,
        config,
        pickupStore,
        pickupTime,
        isSaving,
        orderId,
        message,
      ];
}


