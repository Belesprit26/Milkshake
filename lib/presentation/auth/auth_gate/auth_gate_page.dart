import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:milkshake/di/locator.dart';
import 'package:milkshake/presentation/orders/order_draft/order_draft_page.dart';
import 'widgets/auth_card.dart';
import 'auth_gate_cubit.dart';

class AuthGatePage extends StatelessWidget {
  const AuthGatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthGateCubit>(),
      child: BlocBuilder<AuthGateCubit, AuthGateState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (state.isAuthed) {
            return const OrderDraftPage();
          }
          return const _AuthLanding();
        },
      ),
    );
  }
}

class _AuthLanding extends StatelessWidget {
  const _AuthLanding();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Milkshake')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: const AuthCard(),
      ),
    );
  }
}