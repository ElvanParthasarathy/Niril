import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'nalvaravu_welcome_page.dart';
import '../widgets/auth_components.dart';
import '../../../../../main.dart'; // To access ShellDemoScreen
import '../../../../core/state/app_state.dart';
import '../mode_selector_screen.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  String _email = '';
  String _password = '';
  bool _loading = false;
  String _error = '';

  void _handleLogin() async {
    if (_email.isEmpty || _password.isEmpty) {
      setState(() {
        _error = 'Please fill in all fields.';
      });
      return;
    }

    setState(() {
      _error = '';
      _loading = true;
    });

    // Mock Login Delay
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    if (_email == 'test@niril.com' && _password == 'password') {
      ref.read(isLoggedInProvider.notifier).setLoggedIn(true);
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      ref.read(isLoggedInProvider.notifier).setLoggedIn(true);
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AuthHeader(
            title: 'Niril',
            subtitle: 'Login to access your app',
          ),
          
          const SizedBox(height: 32),

          AuthInput(
            label: 'Email Address',
            placeholder: 'Enter your email',
            value: _email,
            onChange: (val) => setState(() => _email = val),
          ),

          AuthInput(
            label: 'Password',
            placeholder: 'Enter your password',
            value: _password,
            onChange: (val) => setState(() => _password = val),
            isPassword: true,
            errorText: _error.isNotEmpty ? _error : null,
          ),

          const SizedBox(height: 32),

          AuthButton(
            text: 'Sign In',
            loading: _loading,
            onPressed: _handleLogin,
          ),
        ],
      ),
    );
  }
}
