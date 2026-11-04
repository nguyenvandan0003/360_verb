import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../logic/auth_provider.dart';

class AuthModal extends ConsumerStatefulWidget {
  const AuthModal({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AuthModal(),
    );
  }

  @override
  ConsumerState<AuthModal> createState() => _AuthModalState();
}

class _AuthModalState extends ConsumerState<AuthModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final _loginEmailController = TextEditingController(text: 'test@antigravity.dev');
  final _loginPasswordController = TextEditingController(text: 'password123');

  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();

  bool _obscureLoginPassword = true;
  bool _obscureRegisterPassword = true;
  String? _localError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_selectedTabIndex != _tabController.index) {
        setState(() => _selectedTabIndex = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() => _localError = null);

    final success = await ref.read(authProvider.notifier).login(
          _loginEmailController.text,
          _loginPasswordController.passwordText(),
        );

    if (mounted) {
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Đăng nhập thành công! Đã kích hoạt Gia sư AI DeepSeek.'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      } else {
        final err = ref.read(authProvider).errorMessage;
        setState(() => _localError = err ?? 'Đăng nhập không thành công.');
      }
    }
  }

  Future<void> _handleRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;
    setState(() => _localError = null);

    final success = await ref.read(authProvider.notifier).register(
          _registerNameController.text,
          _registerEmailController.text,
          _registerPasswordController.passwordText(),
        );

    if (mounted) {
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Tạo tài khoản thành công! Chào mừng bạn đến với Verb360.'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      } else {
        final err = ref.read(authProvider).errorMessage;
        setState(() => _localError = err ?? 'Đăng ký không thành công.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final textScale = mediaQuery.textScaler.scale(1.0);
    final isCompact = mediaQuery.size.width <= 340 || textScale > 1.15;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 16 : 24,
              vertical: isCompact ? 12 : 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: isCompact ? 8 : 16),

                // Header with AI DeepSeek branding
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isCompact ? 6 : 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.auto_awesome_rounded, color: Colors.white, size: isCompact ? 20 : 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tài Khoản Verb360 & AI',
                            style: TextStyle(fontSize: isCompact ? 15 : 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Đăng nhập để mở khóa Gia sư AI DeepSeek',
                            style: TextStyle(fontSize: isCompact ? 11 : 13, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      padding: isCompact ? EdgeInsets.zero : const EdgeInsets.all(8),
                      constraints: isCompact ? const BoxConstraints() : null,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: isCompact ? 10 : 18),

                // Segmented TabBar
                Container(
                  height: isCompact ? 38 : 44,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    onTap: (index) => setState(() => _selectedTabIndex = index),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey.shade700,
                    labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: isCompact ? 12 : 14),
                    tabs: const [
                      Tab(text: 'Đăng nhập'),
                      Tab(text: 'Tạo tài khoản'),
                    ],
                  ),
                ),
                SizedBox(height: isCompact ? 10 : 16),

                // Error message banner if any
                if (_localError != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _localError!,
                            style: TextStyle(color: Colors.red.shade800, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Dynamic Form Body
                if (_selectedTabIndex == 0)
                  Form(
                    key: _loginFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _loginEmailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            isDense: isCompact,
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.mail_outline_rounded),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isCompact ? 8 : 12),
                          ),
                          validator: (v) {
                            if (v == null || !v.contains('@')) return 'Email không hợp lệ';
                            return null;
                          },
                        ),
                        SizedBox(height: isCompact ? 8 : 14),
                        TextFormField(
                          controller: _loginPasswordController,
                          obscureText: _obscureLoginPassword,
                          decoration: InputDecoration(
                            isDense: isCompact,
                            labelText: 'Mật khẩu',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureLoginPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              ),
                              onPressed: () {
                                setState(() => _obscureLoginPassword = !_obscureLoginPassword);
                              },
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isCompact ? 8 : 12),
                          ),
                          validator: (v) {
                            if (v == null || v.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
                            return null;
                          },
                        ),
                        SizedBox(height: isCompact ? 12 : 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: isCompact ? 10 : 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: authState.isLoading ? null : _handleLogin,
                          child: authState.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Đăng nhập ngay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            _loginEmailController.text = 'test@antigravity.dev';
                            _loginPasswordController.text = 'password123';
                          },
                          child: const Text('Điền nhanh tài khoản mẫu: test@antigravity.dev'),
                        ),
                      ],
                    ),
                  )
                else
                  Form(
                    key: _registerFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _registerNameController,
                          decoration: InputDecoration(
                            isDense: isCompact,
                            labelText: 'Họ và tên của bạn',
                            prefixIcon: const Icon(Icons.person_outline_rounded),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isCompact ? 8 : 12),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Vui lòng nhập tên của bạn';
                            return null;
                          },
                        ),
                        SizedBox(height: isCompact ? 8 : 12),
                        TextFormField(
                          controller: _registerEmailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            isDense: isCompact,
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.mail_outline_rounded),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isCompact ? 8 : 12),
                          ),
                          validator: (v) {
                            if (v == null || !v.contains('@')) return 'Email không hợp lệ';
                            return null;
                          },
                        ),
                        SizedBox(height: isCompact ? 8 : 12),
                        TextFormField(
                          controller: _registerPasswordController,
                          obscureText: _obscureRegisterPassword,
                          decoration: InputDecoration(
                            isDense: isCompact,
                            labelText: 'Mật khẩu (tối thiểu 8 ký tự)',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureRegisterPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              ),
                              onPressed: () {
                                setState(() => _obscureRegisterPassword = !_obscureRegisterPassword);
                              },
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isCompact ? 8 : 12),
                          ),
                          validator: (v) {
                            if (v == null || v.length < 8) return 'Mật khẩu tối thiểu 8 ký tự';
                            return null;
                          },
                        ),
                        SizedBox(height: isCompact ? 12 : 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: isCompact ? 10 : 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: authState.isLoading ? null : _handleRegister,
                          child: authState.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Tạo tài khoản & Bắt đầu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension on TextEditingController {
  String passwordText() => text.trim();
}
