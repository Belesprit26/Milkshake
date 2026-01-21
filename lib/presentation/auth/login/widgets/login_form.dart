import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:milkshake/di/locator.dart';
import 'package:milkshake/presentation/auth/login/login_bloc.dart';
import 'package:milkshake/presentation/shared/widgets/app_text_field.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key, this.onSuccess});

  final VoidCallback? onSuccess;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LoginBloc>(),
      child: Builder(
        builder: (context) {
          return BlocListener<LoginBloc, LoginState>(
            listenWhen: (p, n) => p.status != n.status,
            listener: (context, state) {
              if (state.status == LoginStatus.success) {
                onSuccess?.call();
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BlocBuilder<LoginBloc, LoginState>(
                  buildWhen: (p, n) => p.email != n.email,
                  builder: (context, state) {
                    return AppTextField(
                      label: 'Email',
                      hintText: 'olivia@untitledui.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      onChanged: (v) => context.read<LoginBloc>().add(LoginEmailChanged(v)),
                    );
                  },
                ),
                const SizedBox(height: 12),
                BlocBuilder<LoginBloc, LoginState>(
                  buildWhen: (p, n) => p.password != n.password,
                  builder: (context, state) {
                    return AppTextField(
                      label: 'Password',
                      hintText: 'Insert',
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onChanged: (v) => context.read<LoginBloc>().add(LoginPasswordChanged(v)),
                      onSubmitted: (_) => context.read<LoginBloc>().add(const LoginSubmitted()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                BlocBuilder<LoginBloc, LoginState>(
                  buildWhen: (p, n) => p.status != n.status || p.error != n.error,
                  builder: (context, state) {
                    if (state.error == null) return const SizedBox.shrink();
                    return Text(
                      state.error!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    );
                  },
                ),
                const SizedBox(height: 12),
                BlocBuilder<LoginBloc, LoginState>(
                  buildWhen: (p, n) => p.status != n.status,
                  builder: (context, state) {
                    return FilledButton(
                      onPressed: state.status == LoginStatus.submitting
                          ? null
                          : () => context.read<LoginBloc>().add(const LoginSubmitted()),
                      child: Text(state.status == LoginStatus.submitting ? 'Logging in…' : 'Log in'),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
