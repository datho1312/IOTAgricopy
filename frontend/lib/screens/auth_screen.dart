// lib/screens/auth_screen.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import '../core/widgets/gradient_button.dart';
import '../core/widgets/outline_danger_button.dart';
import '../providers/auth_controller.dart';

/// Authentication screen with two tabs: Đăng nhập & Đăng ký.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _confirmPwdCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _fullNameCtrl.dispose();
    _confirmPwdCtrl.dispose();
    super.dispose();
  }

  // Simple email regex.
  bool _isValidEmail(String email) =>
      RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+").hasMatch(email);

  InputDecoration _fieldDecoration({
    required String label,
    Widget? suffixIcon,
  }) {
    const radius = BorderRadius.all(Radius.circular(16));
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: AppColors.primaryText,
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.54),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      suffixIcon: suffixIcon,
      enabledBorder: const OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: AppColors.sage, width: 2),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: AppColors.forestGreen, width: 2.5),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: AppColors.danger, width: 1.5),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: AppColors.danger, width: 2.5),
      ),
    );
  }

  Widget _fieldShell(Widget child) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      boxShadow: [
        BoxShadow(
          color: AppColors.forestGreen.withValues(alpha: 0.28),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: child,
  );

  void _submit() async {
    final isLogin = ref.read(authTabProvider) == 0;
    if (!_formKey.currentState!.validate()) return;
    final authCtrl = ref.read(authControllerProvider.notifier);
    if (isLogin) {
      await authCtrl.login(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
    } else {
      await authCtrl.signUp(
        fullName: _fullNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
    }
    // Errors are handled via state.error -> SnackBar.
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLogin = ref.watch(authTabProvider) == 0;

    // Show any auth error as a SnackBar.
    if (authState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(authState.error!)));
        // Clear error after showing.
        ref.read(authControllerProvider.notifier).clearError();
      });
    }

    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo placeholder (you can replace with an asset later).
                const Icon(
                  Icons.local_florist,
                  size: 80,
                  color: AppColors.forestGreen,
                ),
                const SizedBox(height: 12),
                Text(
                  'Trồng Rau Đô Thị Nhàn Tênh',
                  style: AppText.heading(context, fontSize: 24),
                ),
                const SizedBox(height: 4),
                Text(
                  'Trồng rau sạch ngay trên mặt bếp — Aerogreen lo phần còn lại.',
                  textAlign: TextAlign.center,
                  style: AppText.label(
                    context,
                  ).copyWith(color: AppColors.secondaryText),
                ),
                const SizedBox(height: 32),
                // Segmented tab
                _buildTabBar(),
                const SizedBox(height: 24),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(28)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.30),
                              Colors.white.withValues(alpha: 0.08),
                            ],
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(28),
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.46),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.forestGreen.withValues(
                                alpha: 0.2,
                              ),
                              blurRadius: 30,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              if (!isLogin) ...[
                                _fieldShell(
                                  TextFormField(
                                    controller: _fullNameCtrl,
                                    decoration: _fieldDecoration(
                                      label: 'Họ và tên',
                                    ),
                                    validator: (v) => v == null || v.isEmpty
                                        ? 'Vui lòng nhập họ và tên'
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                              _fieldShell(
                                TextFormField(
                                  controller: _emailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: _fieldDecoration(label: 'Email'),
                                  validator: (v) =>
                                      v == null || !_isValidEmail(v)
                                      ? 'Email không hợp lệ'
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _fieldShell(
                                TextFormField(
                                  controller: _passwordCtrl,
                                  obscureText: _obscurePassword,
                                  decoration: _fieldDecoration(
                                    label: 'Mật khẩu',
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                      onPressed: () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      ),
                                    ),
                                  ),
                                  validator: (v) => v == null || v.length < 8
                                      ? 'Mật khẩu ít nhất 8 ký tự'
                                      : null,
                                ),
                              ),
                              if (!isLogin) ...[
                                const SizedBox(height: 12),
                                _fieldShell(
                                  TextFormField(
                                    controller: _confirmPwdCtrl,
                                    obscureText: _obscureConfirm,
                                    decoration: _fieldDecoration(
                                      label: 'Xác nhận mật khẩu',
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirm
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        onPressed: () => setState(
                                          () => _obscureConfirm =
                                              !_obscureConfirm,
                                        ),
                                      ),
                                    ),
                                    validator: (v) => v != _passwordCtrl.text
                                        ? 'Mật khẩu không khớp'
                                        : null,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),
                              // Action button
                              isLogin
                                  ? GradientButton(
                                      label: 'Đăng nhập',
                                      isLoading: authState.isLoading,
                                      onPressed: authState.isLoading
                                          ? null
                                          : _submit,
                                    )
                                  : GradientButton(
                                      label: 'Đăng ký',
                                      isLoading: authState.isLoading,
                                      onPressed: authState.isLoading
                                          ? null
                                          : _submit,
                                    ),
                              const SizedBox(height: 16),
                              // Divider with text
                              Row(
                                children: const [
                                  Expanded(child: Divider()),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text('hoặc tiếp tục với'),
                                  ),
                                  Expanded(child: Divider()),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Social buttons (simulated, outlined)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  SizedBox(
                                    width: 92,
                                    child: OutlineDangerButton(
                                      label: '',
                                      onPressed: null, // simulate only
                                      icon: Icons.g_mobiledata,
                                      iconSize: 32,
                                      iconOnly: true,
                                      color: AppColors.forestGreen,
                                      semanticsLabel: 'Đăng nhập bằng Google',
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  SizedBox(
                                    width: 92,
                                    child: OutlineDangerButton(
                                      label: '',
                                      onPressed: null,
                                      icon: Icons.apple,
                                      iconSize: 32,
                                      iconOnly: true,
                                      color: AppColors.forestGreen,
                                      semanticsLabel: 'Đăng nhập bằng Apple',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Footnote with links
                              Wrap(
                                alignment: WrapAlignment.center,
                                children: [
                                  Text(
                                    'Tiếp tục đồng nghĩa bạn đồng ý với ',
                                    style: AppText.body(context),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      // In a real app you would navigate to the terms.
                                    },
                                    child: Text(
                                      'Điều khoản',
                                      style: AppText.body(context).copyWith(
                                        color: AppColors.forestGreen,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                  Text(' & ', style: AppText.body(context)),
                                  GestureDetector(
                                    onTap: () {},
                                    child: Text(
                                      'Quyền riêng tư',
                                      style: AppText.body(context).copyWith(
                                        color: AppColors.forestGreen,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                  Text('.', style: AppText.body(context)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Simple segmented control built with ToggleButtons.
  Widget _buildTabBar() {
    final selected = ref.watch(authTabProvider);
    return ToggleButtons(
      isSelected: [selected == 0, selected == 1],
      borderRadius: BorderRadius.circular(30),
      fillColor: AppColors.forestGreen,
      selectedColor: Colors.white,
      color: AppColors.forestGreen,
      borderColor: AppColors.forestGreen,
      borderWidth: 2,
      onPressed: (index) => ref.read(authTabProvider.notifier).state = index,
      children: const [
        SizedBox(
          width: 120,
          height: 42,
          child: Center(child: Text('Đăng nhập')),
        ),
        SizedBox(width: 120, height: 42, child: Center(child: Text('Đăng ký'))),
      ],
    );
  }
}
