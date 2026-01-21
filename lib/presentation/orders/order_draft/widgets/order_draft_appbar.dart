import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:milkshake/di/locator.dart';
import 'package:milkshake/domain/auth/entities/auth_user.dart';
import 'package:milkshake/domain/auth/repositories/auth_repository.dart';
import 'package:milkshake/domain/auth/usecases/sign_out.dart';
import 'package:milkshake/presentation/management/lookup_management/lookup_management_page.dart';
import 'package:milkshake/presentation/orders/drafts/drafts_page.dart';
import 'package:milkshake/presentation/orders/order_draft/order_draft_bloc.dart';
import 'package:milkshake/presentation/orders/order_history/order_history_page.dart';

import '../../../../core/result/result.dart';

class OrderDraftAppBar extends StatelessWidget implements PreferredSizeWidget {
  const OrderDraftAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final auth = getIt<AuthRepository>();

    return StreamBuilder<AuthUser?>(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user == null) {
          return AppBar(title: const Text('Milky Shaky'));
        }

        return FutureBuilder<Result<String?>>(
          future: auth.getRole(),
          builder: (context, roleSnap) {
            final roleRes = roleSnap.data;
            final role = roleRes is Ok<String?> ? roleRes.value : null;
            final isManager = role == 'manager';
            final title = roleRes is Ok<String?>
                ? 'Milky Shaky - ${isManager ? 'Manager' : 'Patron'}'
                : 'Milky Shaky';

            return AppBar(
              title: Text(title),
              actions: [
                if (isManager)
                  IconButton(
                    tooltip: 'Lookup management',
                    onPressed: () async {
                      final bloc = context.read<OrderDraftBloc>();
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LookupManagementPage()),
                      );
                      if (bloc.isClosed) return;
                      bloc.add(OrderDraftStarted(orderId: bloc.state.orderId));
                    },
                    icon: const Icon(Icons.admin_panel_settings),
                  ),
                IconButton(
                  tooltip: 'Drafts',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const DraftsPage()),
                    );
                  },
                  icon: Icon(Icons.edit_note),
                ),
                IconButton(
                  tooltip: 'Orders',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const OrderHistoryPage()),
                    );
                  },
                  icon: const Icon(Icons.receipt_long),
                ),
                IconButton(
                  tooltip: 'Sign out',
                  onPressed: () async {
                    await getIt<SignOut>()();
                  },
                  icon: const Icon(Icons.logout),
                ),
              ],
            );
          },
        );
      },
    );
  }
}