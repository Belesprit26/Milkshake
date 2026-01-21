import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import '../../shared/widgets/app_form_container.dart';
import '../login/login_page.dart';
import '../sign_up/sign_up_page.dart';

enum _AuthMode { login, signup }

class AuthCard extends StatefulWidget {
  const AuthCard({super.key});

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  var _mode = _AuthMode.login;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppFormContainer(
      title: _mode == _AuthMode.login ? 'Log in to your account' : 'Create account',
      subtitle: _mode == _AuthMode.login
          ? 'Welcome back! Please enter your details.'
          : 'Enter your details to sign up.',
      maxWidth: 460,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F2F7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFD7DCE6)),
            ),
            child: Row(
              children: [
                _TabPill(
                  label: 'Sign up',
                  selected: _mode == _AuthMode.signup,
                  onPressed: () => setState(() => _mode = _AuthMode.signup),
                ),
                _TabPill(
                  label: 'Login',
                  selected: _mode == _AuthMode.login,
                  onPressed: () => setState(() => _mode = _AuthMode.login),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (_mode == _AuthMode.login)
            const LoginForm()
          else
            const SignUpForm(),

          const SizedBox(height: 16),
          _BottomSwitchText(
            mode: _mode,
            onSwitch: () {
              setState(() {
                _mode = _mode == _AuthMode.login ? _AuthMode.signup : _AuthMode.login;
              });
            },
            bodyStyle: theme.textTheme.bodyMedium,
            linkStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomSwitchText extends StatelessWidget {
  const _BottomSwitchText({
    required this.mode,
    required this.onSwitch,
    required this.bodyStyle,
    required this.linkStyle,
  });

  final _AuthMode mode;
  final VoidCallback onSwitch;
  final TextStyle? bodyStyle;
  final TextStyle? linkStyle;

  @override
  Widget build(BuildContext context) {
    final isLogin = mode == _AuthMode.login;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: isLogin ? "Don’t have an account? " : "Already have an account? ",
            style: bodyStyle,
          ),
          TextSpan(
            text: isLogin ? "Sign up" : "Log in",
            style: linkStyle,
            recognizer: TapGestureRecognizer()..onTap = onSwitch,
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: selected ? const Color(0xFF101828) : const Color(0xFF667085),
            textStyle: theme.textTheme.labelLarge,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}


