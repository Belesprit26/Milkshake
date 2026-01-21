import 'package:flutter/material.dart';
import 'package:milkshake/presentation/auth/login/widgets/login_form.dart';
import 'package:milkshake/presentation/shared/widgets/app_form_container.dart';


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



