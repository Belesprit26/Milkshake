import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/result/result.dart';
import '../../../di/locator.dart';
import '../../../domain/auth/repositories/auth_repository.dart';
import '../../../domain/catalog/entities/lookup_item.dart';
import '../../../domain/catalog/entities/lookup_type.dart';
import '../../../domain/catalog/repositories/catalog_repository.dart';
import '../../../domain/catalog/repositories/config_repository.dart';
import '../../../presentation/shared/formatters/zar_format.dart';

part 'lookup_management_event.dart';
part 'lookup_management_state.dart';

class LookupManagementBloc extends Bloc<LookupManagementEvent, LookupManagementState> {
  LookupManagementBloc({
    AuthRepository? authRepository,
    CatalogRepository? catalogRepository,
    ConfigRepository? configRepository,
  })  : _auth = authRepository ?? getIt<AuthRepository>(),
        _catalog = catalogRepository ?? getIt<CatalogRepository>(),
        _config = configRepository ?? getIt<ConfigRepository>(),
        super(const LookupManagementState.initial()) {
    on<LookupManagementStarted>(_onStarted);
    on<LookupManagementAddNewPressed>(_onAddNew);
    on<LookupManagementEditPressed>(_onEdit);
    on<LookupManagementDeletePressed>(_onDelete);
    on<LookupManagementFormNameChanged>((e, emit) => emit(state.copyWith(formName: e.value)));
    on<LookupManagementFormTypeChanged>((e, emit) => emit(state.copyWith(formSection: e.value)));
    on<LookupManagementFormValueChanged>((e, emit) => emit(state.copyWith(formValue: e.value)));
    on<LookupManagementCancelPressed>(_onCancel);
    on<LookupManagementSavePressed>(_onSave);
  }

  final AuthRepository _auth;
  final CatalogRepository _catalog;
  final ConfigRepository _config;

  Future<void> _onStarted(
    LookupManagementStarted event,
    Emitter<LookupManagementState> emit,
  ) async {
    emit(state.copyWith(status: LookupManagementStatus.loading, clearError: true));

    final roleRes = await _auth.getRole();
    if (roleRes is Err) {
      emit(state.copyWith(status: LookupManagementStatus.failure, error: (roleRes as Err).failure.message));
      return;
    }
    final role = (roleRes as Ok<String?>).value;
    if (role != 'manager') {
      emit(state.copyWith(status: LookupManagementStatus.unauthorized));
      return;
    }

    final flavoursRes = await _catalog.listLookups(LookupType.flavour);
    final toppingsRes = await _catalog.listLookups(LookupType.topping);
    final configRes = await _config.getCurrentConfig();
    final configTsRes = await _config.getCurrentConfigUpdatedAtMillis();

    if (flavoursRes is Err || toppingsRes is Err || configRes is Err || configTsRes is Err) {
      final msg = [
        if (flavoursRes is Err) (flavoursRes as Err).failure.message,
        if (toppingsRes is Err) (toppingsRes as Err).failure.message,
        if (configRes is Err) (configRes as Err).failure.message,
        if (configTsRes is Err) (configTsRes as Err).failure.message,
      ].where((x) => x.trim().isNotEmpty).join('\n');
      emit(state.copyWith(status: LookupManagementStatus.failure, error: msg.isEmpty ? 'Failed to load.' : msg));
      return;
    }

    final config = (configRes as Ok).value;
    emit(
      state.copyWith(
        status: LookupManagementStatus.ready,
        flavours: (flavoursRes as Ok<List<LookupItem>>).value,
        toppings: (toppingsRes as Ok<List<LookupItem>>).value,
        vatPercent: config.vatPercent.value,
        maxDrinks: config.maxDrinks.value,
        baseDrinkPriceCents: config.baseDrinkPrice.cents,
        configUpdatedAtMillis: (configTsRes as Ok<int>).value,
        formSection: ManagementSection.flavours,
        clearFormId: true,
        formName: '',
        formValue: '',
      ),
    );
  }

  Future<void> _onAddNew(
    LookupManagementAddNewPressed event,
    Emitter<LookupManagementState> emit,
  ) async {
    emit(
      state.copyWith(
        formSection: event.section,
        clearFormId: true,
        formName: '',
        formValue: '',
        clearError: true,
      ),
    );
  }

  Future<void> _onEdit(
    LookupManagementEditPressed event,
    Emitter<LookupManagementState> emit,
  ) async {
    if (event.section == ManagementSection.config) {
      final value = switch (event.id) {
        'maxDrinks' => state.maxDrinks.toString(),
        'vatPercent' => state.vatPercent.toString(),
        'baseDrinkPriceCents' => formatZarCents(state.baseDrinkPriceCents).replaceAll('R', ''),
        _ => '',
      };
      emit(
        state.copyWith(
          formSection: ManagementSection.config,
          formId: event.id,
          formName: _configName(event.id),
          formValue: value,
          clearError: true,
        ),
      );
      return;
    }

    final list = event.section == ManagementSection.flavours ? state.flavours : state.toppings;
    final item = list.firstWhere((x) => x.id == event.id);
    emit(
      state.copyWith(
        formSection: event.section,
        formId: item.id,
        formName: item.name,
        formValue: formatZar(item.priceDelta).replaceAll('R', ''),
        clearError: true,
      ),
    );
  }

  Future<void> _onDelete(
    LookupManagementDeletePressed event,
    Emitter<LookupManagementState> emit,
  ) async {
    final user = _auth.currentUser();
    if (user == null) {
      emit(state.copyWith(status: LookupManagementStatus.failure, error: 'Not signed in.'));
      return;
    }
    if (event.section == ManagementSection.config) return;

    emit(state.copyWith(status: LookupManagementStatus.saving, clearError: true));
    final res = await _catalog.deactivateLookup(id: event.id, actorUid: user.uid);
    if (res is Err) {
      emit(state.copyWith(status: LookupManagementStatus.failure, error: res.failure.message));
      return;
    }
    add(const LookupManagementStarted());
  }

  Future<void> _onCancel(
    LookupManagementCancelPressed event,
    Emitter<LookupManagementState> emit,
  ) async {
    emit(state.copyWith(clearFormId: true, formName: '', formValue: '', clearError: true));
  }

  Future<void> _onSave(
    LookupManagementSavePressed event,
    Emitter<LookupManagementState> emit,
  ) async {
    final user = _auth.currentUser();
    if (user == null) {
      emit(state.copyWith(status: LookupManagementStatus.failure, error: 'Not signed in.'));
      return;
    }

    final name = state.formName.trim();
    final value = state.formValue.trim();
    if (state.formSection != ManagementSection.config && name.isEmpty) {
      emit(state.copyWith(status: LookupManagementStatus.failure, error: 'Name is required.'));
      return;
    }
    if (value.isEmpty) {
      emit(state.copyWith(status: LookupManagementStatus.failure, error: 'Value is required.'));
      return;
    }

    emit(state.copyWith(status: LookupManagementStatus.saving, clearError: true));

    if (state.formSection == ManagementSection.config) {
      final field = state.formId ?? _defaultConfigFieldForName(state.formName);
      final parsed = int.tryParse(value);
      if (field == 'maxDrinks' || field == 'vatPercent') {
        if (parsed == null) {
          emit(state.copyWith(status: LookupManagementStatus.failure, error: 'Value must be numeric.'));
          return;
        }
        final res = await _config.updateCurrentConfig(
          vatPercent: field == 'vatPercent' ? parsed : null,
          maxDrinks: field == 'maxDrinks' ? parsed : null,
          actorUid: user.uid,
        );
        if (res is Err) {
          emit(state.copyWith(status: LookupManagementStatus.failure, error: res.failure.message));
          return;
        }
        add(const LookupManagementStarted());
        return;
      }

      final cents = parseZarToCents(value);
      final res = await _config.updateCurrentConfig(
        baseDrinkPriceCents: cents,
        actorUid: user.uid,
      );
      if (res is Err) {
        emit(state.copyWith(status: LookupManagementStatus.failure, error: res.failure.message));
        return;
      }
      add(const LookupManagementStarted());
      return;
    }

    final cents = parseZarToCents(value);
    final type = state.formSection == ManagementSection.flavours ? LookupType.flavour : LookupType.topping;
    final id = state.formId;

    if (id == null) {
      final res = await _catalog.createLookup(
        type: type,
        name: name,
        priceDeltaCents: cents,
        actorUid: user.uid,
      );
      switch (res) {
        case Err(failure: final f):
          emit(state.copyWith(status: LookupManagementStatus.failure, error: f.message));
          return;
        case Ok():
          break;
      }
    } else {
      final res = await _catalog.updateLookup(
        id: id,
        type: type,
        name: name,
        priceDeltaCents: cents,
        active: true,
        actorUid: user.uid,
      );
      switch (res) {
        case Err(failure: final f):
          emit(state.copyWith(status: LookupManagementStatus.failure, error: f.message));
          return;
        case Ok():
          break;
      }
    }

    add(const LookupManagementStarted());
  }

  String _configName(String field) {
    return switch (field) {
      'maxDrinks' => 'Maximum Drinks',
      'vatPercent' => 'VAT',
      'baseDrinkPriceCents' => 'Base Drink Price',
      _ => 'Config',
    };
  }

  String _defaultConfigFieldForName(String name) {
    final n = name.toLowerCase();
    if (n.contains('max')) return 'maxDrinks';
    if (n.contains('vat')) return 'vatPercent';
    if (n.contains('base')) return 'baseDrinkPriceCents';
    return 'maxDrinks';
  }
}


