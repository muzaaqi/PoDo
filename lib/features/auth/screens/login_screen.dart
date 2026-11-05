import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:podo/app/routes.dart';
import 'package:podo/features/auth/repositories/auth_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Email dan password tidak boleh kosong.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final lecturerId = await AuthRepository.instance.login(email, password);

      if (!mounted) return;

      if (lecturerId != null) {
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      } else {
        setState(() {
          _errorMessage = 'Email atau password tidak sesuai.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Terjadi kesalahan saat masuk: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Portal Dosen',
                  textAlign: TextAlign.center,
                  style: context.theme.typography.display.xl2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Masuk untuk mengakses portal akademik Anda',
                  textAlign: TextAlign.center,
                  style: context.theme.typography.body.sm.copyWith(
                    color: context.theme.colors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 32),
                if (_errorMessage != null) ...[
                  FAlert(
                    variant: FAlertVariant.destructive,
                    title: Text(_errorMessage!),
                  ),
                  const SizedBox(height: 16),
                ],
                FTextField(
                  label: const Text('Email / Username'),
                  hint: 'Contoh: dosen@kampus.id',
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  control: FTextFieldControl.managed(controller: _emailController),
                ),
                const SizedBox(height: 16),
                FTextField.password(
                  label: const Text('Password'),
                  hint: 'Masukkan password',
                  control: FTextFieldControl.managed(controller: _passwordController),
                ),
                const SizedBox(height: 24),
                FButton(
                  onPress: _isLoading ? null : _handleLogin,
                  child: Text(_isLoading ? 'Memproses...' : 'Masuk'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
