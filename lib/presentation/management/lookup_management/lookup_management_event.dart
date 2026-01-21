part of 'lookup_management_bloc.dart';

sealed class LookupManagementEvent extends Equatable {
  const LookupManagementEvent();

  @override
  List<Object?> get props => [];
}

final class LookupManagementStarted extends LookupManagementEvent {
  const LookupManagementStarted();
}

final class LookupManagementAddNewPressed extends LookupManagementEvent {
  const LookupManagementAddNewPressed(this.section);
  final ManagementSection section;

  @override
  List<Object?> get props => [section];
}

final class LookupManagementEditPressed extends LookupManagementEvent {
  const LookupManagementEditPressed(this.section, this.id);
  final ManagementSection section;
  final String id;

  @override
  List<Object?> get props => [section, id];
}

final class LookupManagementDeletePressed extends LookupManagementEvent {
  const LookupManagementDeletePressed(this.section, this.id);
  final ManagementSection section;
  final String id;

  @override
  List<Object?> get props => [section, id];
}

final class LookupManagementFormNameChanged extends LookupManagementEvent {
  const LookupManagementFormNameChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

final class LookupManagementFormTypeChanged extends LookupManagementEvent {
  const LookupManagementFormTypeChanged(this.value);
  final ManagementSection value;

  @override
  List<Object?> get props => [value];
}

final class LookupManagementFormValueChanged extends LookupManagementEvent {
  const LookupManagementFormValueChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

final class LookupManagementCancelPressed extends LookupManagementEvent {
  const LookupManagementCancelPressed();
}

final class LookupManagementSavePressed extends LookupManagementEvent {
  const LookupManagementSavePressed();
}


