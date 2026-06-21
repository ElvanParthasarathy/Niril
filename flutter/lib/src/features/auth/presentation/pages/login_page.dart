import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'nalvaravu_welcome_page.dart';
import '../widgets/auth_components.dart';
import '../../../../../main.dart'; // To access ShellDemoScreen
import '../../../../core/state/app_state.dart';
import '../mode_selector_screen.dart';
import '../../../../localization/locale_provider.dart';

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
        _error = 'pleaseFillAllFields'.tr(context, ref);
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
          AuthAnimatedElement(
            delayIndex: 0,
            child: AuthBackButton(
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(height: 16),
          AuthHeader(
            title: 'nirilBrand'.tr(context, ref), // Brand name
            subtitle: 'loginSubtitle'.tr(context, ref),
          ),
          
          const SizedBox(height: 32),

          AuthInput(
            label: 'emailAddress'.tr(context, ref),
            placeholder: 'enterEmail'.tr(context, ref),
            value: _email,
            onChange: (val) => setState(() => _email = val),
          ),

          AuthInput(
            label: 'password'.tr(context, ref),
            placeholder: 'enterPassword'.tr(context, ref),
            value: _password,
            onChange: (val) => setState(() => _password = val),
            isPassword: true,
            errorText: _error.isNotEmpty ? _error : null,
          ),

          const SizedBox(height: 32),

          AuthButton(
            text: 'signIn'.tr(context, ref),
            loading: _loading,
            onPressed: _handleLogin,
          ),
        ],
      ),
    );
  }
}
