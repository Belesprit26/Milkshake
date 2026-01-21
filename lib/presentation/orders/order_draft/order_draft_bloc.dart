import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/result/result.dart';
import '../../../domain/catalog/entities/config_snapshot.dart';
import '../../../domain/catalog/entities/lookup_item_snapshot.dart';
import '../../../domain/catalog/entities/lookup_type.dart';
import '../../../domain/catalog/entities/order_history_summary.dart';
import '../../../domain/catalog/usecases/get_active_lookups.dart';
import '../../../domain/catalog/usecases/get_current_config.dart';
import '../../../domain/orders/entities/drink_item.dart';
import '../../../domain/orders/entities/order_draft.dart';
import '../../../domain/orders/entities/order_status.dart';
import '../../../domain/orders/entities/order_totals.dart';
import '../../../domain/orders/repositories/order_repository.dart';
import '../../../domain/orders/usecases/calculate_order_totals.dart';
import '../../../domain/auth/repositories/auth_repository.dart';

part 'order_draft_event.dart';
part 'order_draft_state.dart';

class OrderDraftBloc extends Bloc<OrderDraftEvent, OrderDraftState> {
  OrderDraftBloc({
    required GetCurrentConfig getCurrentConfig,
    required GetActiveLookups getActiveLookups,
    required OrderRepository orderRepository,
    required AuthRepository authRepository,
    required CalculateOrderTotals calculateOrderTotals,
  })  : _getCurrentConfig = getCurrentConfig,
        _getActiveLookups = getActiveLookups,
        _orderRepository = orderRepository,
        _authRepository = authRepository,
        _calculateOrderTotals = calculateOrderTotals,
        super(const OrderDraftState.initial()) {
    on<OrderDraftStarted>(_onStarted);
    on<OrderDraftDrinkCountChanged>(_onDrinkCountChanged);
    on<OrderDraftSelectedDefaults>(_onSelectedDefaults);
    on<OrderDraftDrinkSelectionChanged>(_onDrinkSelectionChanged);
    on<OrderDraftPickupStoreChanged>(_onPickupStoreChanged);
    on<OrderDraftPickupTimeChanged>(_onPickupTimeChanged);
    on<OrderDraftSavePressed>(_onSavePressed);
  }

  final GetCurrentConfig _getCurrentConfig;
  final GetActiveLookups _getActiveLookups;
  final OrderRepository _orderRepository;
  final AuthRepository _authRepository;
  final CalculateOrderTotals _calculateOrderTotals;

  Future<void> _onStarted(
    OrderDraftStarted event,
    Emitter<OrderDraftState> emit,
  ) async {
    emit(state.copyWith(status: OrderDraftStatus.loading));

    final configRes = await _getCurrentConfig();
    if (configRes is Err) {
      emit(state.copyWith(status: OrderDraftStatus.failure));
      return;
    }
    final config = (configRes as Ok<ConfigSnapshot>).value;

    final flavourRes = await _getActiveLookups(LookupType.flavour);
    final toppingRes = await _getActiveLookups(LookupType.topping);
    final consistencyRes = await _getActiveLookups(LookupType.consistency);
    final storeRes = await _getActiveLookups(LookupType.store);

    if (flavourRes is Err ||
        toppingRes is Err ||
        consistencyRes is Err ||
        storeRes is Err) {
      emit(state.copyWith(status: OrderDraftStatus.failure));
      return;
    }

    final flavours = (flavourRes as Ok<List<LookupItemSnapshot>>).value;
    final toppings = (toppingRes as Ok<List<LookupItemSnapshot>>).value;
    final consistencies = (consistencyRes as Ok<List<LookupItemSnapshot>>).value;
    final stores = (storeRes as Ok<List<LookupItemSnapshot>>).value;

    if (event.orderId != null && event.orderId!.trim().isNotEmpty) {
      final user = _authRepository.currentUser();
      if (user == null) {
        emit(state.copyWith(status: OrderDraftStatus.failure, message: 'Not signed in.'));
        return;
      }

      final orderRes = await _orderRepository.getById(event.orderId!);
      if (orderRes is Err) {
        emit(state.copyWith(status: OrderDraftStatus.failure, message: (orderRes as Err).failure.message));
        return;
      }
      final order = (orderRes as Ok<OrderDraft>).value;
      if (order.uid != user.uid) {
        emit(state.copyWith(status: OrderDraftStatus.failure, message: 'Order does not belong to you.'));
        return;
      }

      List<LookupItemSnapshot> ensureIncluded(
        List<LookupItemSnapshot> list,
        LookupItemSnapshot selected,
      ) {
        return list.any((x) => x.id == selected.id) ? list : [selected, ...list];
      }

      final mergedFlavours = order.items.fold<List<LookupItemSnapshot>>(
        flavours,
        (acc, d) => ensureIncluded(acc, d.flavour),
      );
      final mergedToppings = order.items.fold<List<LookupItemSnapshot>>(
        toppings,
        (acc, d) => ensureIncluded(acc, d.topping),
      );
      final mergedConsistencies = order.items.fold<List<LookupItemSnapshot>>(
        consistencies,
        (acc, d) => ensureIncluded(acc, d.consistency),
      );
      final mergedStores = ensureIncluded(stores, order.pickupStore);

      emit(
        state.copyWith(
          status: OrderDraftStatus.ready,
          config: order.configSnapshot,
          flavours: mergedFlavours,
          toppings: mergedToppings,
          consistencies: mergedConsistencies,
          stores: mergedStores,
          drinkCount: order.items.length,
          drinks: order.items,
          totals: order.totals,
          pickupStore: order.pickupStore,
          pickupTime: order.pickupTime,
          orderId: order.id,
          message: null,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: OrderDraftStatus.ready,
        config: config,
        flavours: flavours,
        toppings: toppings,
        consistencies: consistencies,
        stores: stores,
        drinkCount: 1,
        pickupStore: stores.isNotEmpty ? stores.first : null,
        pickupTime: '12:00',
      ),
    );

    add(const OrderDraftSelectedDefaults());
  }

  Future<void> _onSelectedDefaults(
    OrderDraftSelectedDefaults event,
    Emitter<OrderDraftState> emit,
  ) async {
    if (state.status != OrderDraftStatus.ready) return;
    if (state.config == null ||
        state.flavours.isEmpty ||
        state.toppings.isEmpty ||
        state.consistencies.isEmpty ||
        state.stores.isEmpty) {
      return;
    }

    final count = state.drinkCount;
    final drinks = List<DrinkItem>.generate(
      count,
      (_) => DrinkItem(
        flavour: state.flavours.first,
        topping: state.toppings.first,
        consistency: state.consistencies.first,
      ),
    );

    final totals = _recalculate(drinks: drinks);

    emit(state.copyWith(drinks: drinks, totals: totals));
  }

  Future<void> _onDrinkCountChanged(
    OrderDraftDrinkCountChanged event,
    Emitter<OrderDraftState> emit,
  ) async {
    if (state.status != OrderDraftStatus.ready) return;
    final cfg = state.config;
    if (cfg == null) return;

    final max = cfg.maxDrinks.value;
    final next = event.count.clamp(1, max);

    emit(state.copyWith(drinkCount: next));
    add(const OrderDraftSelectedDefaults());
  }

  Future<void> _onDrinkSelectionChanged(
    OrderDraftDrinkSelectionChanged event,
    Emitter<OrderDraftState> emit,
  ) async {
    if (state.status != OrderDraftStatus.ready) return;
    if (event.index < 0 || event.index >= state.drinks.length) return;

    final current = state.drinks[event.index];
    final updated = DrinkItem(
      flavour: event.flavour ?? current.flavour,
      topping: event.topping ?? current.topping,
      consistency: event.consistency ?? current.consistency,
    );

    final nextDrinks = [...state.drinks];
    nextDrinks[event.index] = updated;

    final totals = _recalculate(drinks: nextDrinks);
    emit(state.copyWith(drinks: nextDrinks, totals: totals));
  }

  Future<void> _onPickupStoreChanged(
    OrderDraftPickupStoreChanged event,
    Emitter<OrderDraftState> emit,
  ) async {
    if (state.status != OrderDraftStatus.ready) return;
    emit(state.copyWith(pickupStore: event.store));
  }

  Future<void> _onPickupTimeChanged(
    OrderDraftPickupTimeChanged event,
    Emitter<OrderDraftState> emit,
  ) async {
    if (state.status != OrderDraftStatus.ready) return;
    emit(state.copyWith(pickupTime: event.time));
  }

  Future<void> _onSavePressed(
    OrderDraftSavePressed event,
    Emitter<OrderDraftState> emit,
  ) async {
    if (state.status != OrderDraftStatus.ready) return;
    final cfg = state.config;
    final store = state.pickupStore;
    final time = state.pickupTime;
    final totals = state.totals;

    if (cfg == null || store == null || time == null || totals == null) {
      emit(state.copyWith(message: 'Missing required order fields.'));
      return;
    }

    final user = _authRepository.currentUser();
    if (user == null) {
      emit(state.copyWith(message: 'Please sign in before saving an order.'));
      return;
    }
    final uid = user.uid;

    final draft = OrderDraft(
      id: state.orderId,
      uid: uid,
      status: OrderStatus.draft,
      configSnapshot: cfg,
      items: state.drinks,
      totals: totals,
      pickupStore: store,
      pickupTime: time,
    );

    emit(state.copyWith(isSaving: true, message: null));
    final res = draft.id == null
        ? await _orderRepository.createDraft(draft)
        : await _orderRepository.updateDraft(draft);

    if (res is Err) {
      emit(state.copyWith(isSaving: false, message: (res as Err).failure.message));
      return;
    }

    final saved = (res as Ok<OrderDraft>).value;
    emit(state.copyWith(isSaving: false, orderId: saved.id, message: 'Saved.'));
  }

  OrderTotals _recalculate({required List<DrinkItem> drinks}) {
    final cfg = state.config!;
    return _calculateOrderTotals(
      drinks: drinks,
      config: cfg,
      history: const OrderHistorySummary(
        paidOrdersCount: 0,
        paidOrdersWithAtLeastDrinks: {},
      ),
    );
  }
}


