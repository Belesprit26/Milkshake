import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../di/locator.dart';
import '../../shared/widgets/app_form_container.dart';
import '../../shared/widgets/app_text_field.dart';
import 'login_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log in')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: AppFormContainer(
          title: 'Log in',
          subtitle: 'Use your email address and password.',
          child: LoginForm(
            onSuccess: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatelessWidget {
  const LoginForm({super.key, this.onSuccess});

  final VoidCallback? onSuccess;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LoginBloc>(),
      // IMPORTANT: Use a descendant BuildContext (via Builder) so all `context.read`
      // calls can see the BlocProvider above.
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


