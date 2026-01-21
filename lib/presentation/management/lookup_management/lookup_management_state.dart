part of 'lookup_management_bloc.dart';

enum LookupManagementStatus { initial, loading, ready, saving, unauthorized, failure }

enum ManagementSection { flavours, toppings, config }

class LookupManagementState extends Equatable {
  const LookupManagementState._({
    required this.status,
    required this.flavours,
    required this.toppings,
    required this.vatPercent,
    required this.maxDrinks,
    required this.baseDrinkPriceCents,
    required this.configUpdatedAtMillis,
    required this.formSection,
    required this.formId,
    required this.formName,
    required this.formValue,
    required this.error,
  });

  const LookupManagementState.initial()
      : this._(
          status: LookupManagementStatus.initial,
          flavours: const [],
          toppings: const [],
          vatPercent: 15,
          maxDrinks: 10,
          baseDrinkPriceCents: 0,
          configUpdatedAtMillis: 0,
          formSection: ManagementSection.flavours,
          formId: null,
          formName: '',
          formValue: '',
          error: null,
        );

  final LookupManagementStatus status;
  final List<LookupItem> flavours;
  final List<LookupItem> toppings;

  final int vatPercent;
  final int maxDrinks;
  final int baseDrinkPriceCents;
  final int configUpdatedAtMillis;

  final ManagementSection formSection;
  final String? formId;
  final String formName;
  final String formValue;

  final String? error;

  bool get isEditing => formId != null;

  LookupManagementState copyWith({
    LookupManagementStatus? status,
    List<LookupItem>? flavours,
    List<LookupItem>? toppings,
    int? vatPercent,
    int? maxDrinks,
    int? baseDrinkPriceCents,
    int? configUpdatedAtMillis,
    ManagementSection? formSection,
    String? formId,
    String? formName,
    String? formValue,
    String? error,
    bool clearFormId = false,
    bool clearError = false,
  }) {
    return LookupManagementState._(
      status: status ?? this.status,
      flavours: flavours ?? this.flavours,
      toppings: toppings ?? this.toppings,
      vatPercent: vatPercent ?? this.vatPercent,
      maxDrinks: maxDrinks ?? this.maxDrinks,
      baseDrinkPriceCents: baseDrinkPriceCents ?? this.baseDrinkPriceCents,
      configUpdatedAtMillis: configUpdatedAtMillis ?? this.configUpdatedAtMillis,
      formSection: formSection ?? this.formSection,
      formId: clearFormId ? null : (formId ?? this.formId),
      formName: formName ?? this.formName,
      formValue: formValue ?? this.formValue,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        status,
        flavours,
        toppings,
        vatPercent,
        maxDrinks,
        baseDrinkPriceCents,
        configUpdatedAtMillis,
        formSection,
        formId,
        formName,
        formValue,
        error,
      ];
}


