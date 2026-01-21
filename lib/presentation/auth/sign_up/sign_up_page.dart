import 'package:flutter/material.dart';
import 'package:milkshake/presentation/auth/sign_up/widgets/sign_up_form.dart';
import '../../shared/widgets/app_form_container.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: AppFormContainer(
          title: 'Create account',
          subtitle: 'Enter your details to sign up.',
          child: SignUpForm(
            onSuccess: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }
}

