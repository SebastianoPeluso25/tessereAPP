import 'package:flutter/material.dart';
import 'auth_shell_view.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthShellView(initialMode: AuthMode.login);
  }
}
