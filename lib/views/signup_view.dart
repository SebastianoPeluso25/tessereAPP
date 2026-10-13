import 'package:flutter/material.dart';
import 'auth_shell_view.dart';

class SignupView extends StatelessWidget {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthShellView(initialMode: AuthMode.signup);
  }
}
