import 'package:get_it/get_it.dart';

import '../presentation/auth/auth_gate/auth_gate_cubit.dart';
import '../presentation/auth/login/login_bloc.dart';
import '../presentation/auth/sign_up/sign_up_bloc.dart';
import '../presentation/management/lookup_management/lookup_management_bloc.dart';
import '../presentation/orders/confirm_order/confirm_order_bloc.dart';
import '../presentation/orders/order_draft/order_draft_bloc.dart';
import '../presentation/orders/order_history/order_history_bloc.dart';

void registerPresentation(GetIt getIt) {
  getIt.registerFactory<AuthGateCubit>(() => AuthGateCubit());
  getIt.registerFactory<LoginBloc>(() => LoginBloc());
  getIt.registerFactory<SignUpBloc>(() => SignUpBloc());
  getIt.registerFactory<ConfirmOrderBloc>(() => ConfirmOrderBloc());
  getIt.registerFactory<OrderHistoryBloc>(() => OrderHistoryBloc());
  getIt.registerFactory<LookupManagementBloc>(() => LookupManagementBloc());

  getIt.registerFactory<OrderDraftBloc>(
    () => OrderDraftBloc(
      getCurrentConfig: getIt(),
      getActiveLookups: getIt(),
      orderRepository: getIt(),
      authRepository: getIt(),
      calculateOrderTotals: getIt(),
    ),
  );
}


