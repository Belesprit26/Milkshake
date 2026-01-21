
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:milkshake/di/locator.dart';
import 'package:milkshake/presentation/auth/sign_up/sign_up_bloc.dart';
import 'package:milkshake/presentation/shared/widgets/app_text_field.dart';

class SignUpForm extends StatelessWidget {
  const SignUpForm({super.key, this.onSuccess});

  final VoidCallback? onSuccess;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SignUpBloc>(),
      child: Builder(
        builder: (context) {
          return BlocListener<SignUpBloc, SignUpState>(
            listenWhen: (p, n) => p.status != n.status,
            listener: (context, state) {
              if (state.status == SignUpStatus.success) {
                onSuccess?.call();
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: 'First name',
                  hintText: 'Enter your name',
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.givenName],
                  onChanged: (v) => context.read<SignUpBloc>().add(SignUpFirstNameChanged(v)),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Mobile',
                  hintText: 'Enter your mobile',
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  onChanged: (v) => context.read<SignUpBloc>().add(SignUpMobileChanged(v)),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Email',
                  hintText: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  onChanged: (v) => context.read<SignUpBloc>().add(SignUpEmailChanged(v)),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Password',
                  hintText: 'Create a password',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  onChanged: (v) => context.read<SignUpBloc>().add(SignUpPasswordChanged(v)),
                  onSubmitted: (_) => context.read<SignUpBloc>().add(const SignUpSubmitted()),
                ),
                const SizedBox(height: 12),
                BlocBuilder<SignUpBloc, SignUpState>(
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
                BlocBuilder<SignUpBloc, SignUpState>(
                  buildWhen: (p, n) => p.status != n.status,
                  builder: (context, state) {
                    return FilledButton(
                      onPressed: state.status == SignUpStatus.submitting
                          ? null
                          : () => context.read<SignUpBloc>().add(const SignUpSubmitted()),
                      child: Text(state.status == SignUpStatus.submitting ? 'Creating…' : 'Sign up'),
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
