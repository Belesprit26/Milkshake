part of 'order_draft_bloc.dart';

sealed class OrderDraftEvent extends Equatable {
  const OrderDraftEvent();

  @override
  List<Object?> get props => [];
}

final class OrderDraftStarted extends OrderDraftEvent {
  const OrderDraftStarted();
}

final class OrderDraftDrinkCountChanged extends OrderDraftEvent {
  const OrderDraftDrinkCountChanged(this.count);
  final int count;

  @override
  List<Object?> get props => [count];
}

final class OrderDraftSelectedDefaults extends OrderDraftEvent {
  const OrderDraftSelectedDefaults();
}

final class OrderDraftDrinkSelectionChanged extends OrderDraftEvent {
  const OrderDraftDrinkSelectionChanged({
    required this.index,
    this.flavour,
    this.topping,
    this.consistency,
  });

  final int index;
  final LookupItemSnapshot? flavour;
  final LookupItemSnapshot? topping;
  final LookupItemSnapshot? consistency;

  @override
  List<Object?> get props => [index, flavour, topping, consistency];
}

final class OrderDraftPickupStoreChanged extends OrderDraftEvent {
  const OrderDraftPickupStoreChanged(this.store);
  final LookupItemSnapshot store;

  @override
  List<Object?> get props => [store];
}

final class OrderDraftPickupTimeChanged extends OrderDraftEvent {
  const OrderDraftPickupTimeChanged(this.time);
  final String time;

  @override
  List<Object?> get props => [time];
}

final class OrderDraftSavePressed extends OrderDraftEvent {
  const OrderDraftSavePressed();
}


