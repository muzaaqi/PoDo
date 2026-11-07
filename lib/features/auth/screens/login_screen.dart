import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:podo/app/routes.dart';
import 'package:podo/core/theme/app_colors.dart';
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
  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillDemoAccount() {
    setState(() {
      _emailController.text = 'dosen@kampus.id';
      _passwordController.text = 'password123';
      _emailError = null;
      _passwordError = null;
      _errorMessage = null;
    });
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    String? emailErr;
    String? passwordErr;

    if (email.isEmpty) {
      emailErr = 'Email tidak boleh kosong';
    }

    if (password.isEmpty) {
      passwordErr = 'Password tidak boleh kosong';
    }

    if (emailErr != null || passwordErr != null) {
      setState(() {
        _emailError = emailErr;
        _passwordError = passwordErr;
        _errorMessage = 'Email dan password tidak boleh kosong.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _emailError = null;
      _passwordError = null;
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
    final theme = context.theme;
    final colors = context.appColors;

    return FScaffold(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Branding Header
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
                    style: theme.typography.display.xl2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Masuk untuk mengakses portal akademik Anda',
                    textAlign: TextAlign.center,
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 2. Main Form Card
                  FCard(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
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
                            textInputAction: TextInputAction.next,
                            autocorrect: false,
                            error: _emailError != null ? Text(_emailError!) : null,
                            prefixBuilder: (context, style, variants) =>
                                FTextField.prefixIconBuilder(
                              context,
                              style,
                              variants,
                              const Icon(FLucideIcons.mail),
                            ),
                            control: FTextFieldControl.managed(
                              controller: _emailController,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FTextField.password(
                            label: const Text('Password'),
                            hint: 'Masukkan password',
                            textInputAction: TextInputAction.done,
                            error: _passwordError != null ? Text(_passwordError!) : null,
                            prefixBuilder: (context, style, obscure, variants) =>
                                FTextField.prefixIconBuilder(
                              context,
                              style,
                              variants,
                              const Icon(FLucideIcons.lock),
                            ),
                            control: FTextFieldControl.managed(
                              controller: _passwordController,
                            ),
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
                  const SizedBox(height: 20),

                  // 3. Demo Account Quick-Fill Card
                  Semantics(
                    button: true,
                    label: 'Gunakan akun demo dosen@kampus.id',
                    child: FTappable(
                      onPress: _fillDemoAccount,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: colors.indigo.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: colors.indigo.foreground,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  FLucideIcons.keyRound,
                                  size: 16,
                                  color: colors.indigo.background,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Gunakan Akun Demo',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: colors.indigo.foreground,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    'dosen@kampus.id (otomatis terisi)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: colors.indigo.foreground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
