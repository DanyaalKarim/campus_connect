import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../home/home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final authProvider =
    Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
            (route) => false,
      );
    } else {
      _showError(authProvider.errorMessage ?? 'Login failed');
    }
  }

  Future<void> _googleLogin() async {
    FocusScope.of(context).unfocus();

    final authProvider =
    Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signInWithGoogle();

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
            (route) => false,
      );
    } else {
      _showError(authProvider.errorMessage ?? 'Google sign in failed');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==================== FORGOT PASSWORD ====================
  Future<void> _showForgotPasswordDialog() async {
    final resetEmailController = TextEditingController();
    final resetFormKey = GlobalKey<FormState>();
    bool isLoading = false;

    // Pre-fill email if already entered
    if (_emailController.text.trim().isNotEmpty) {
      resetEmailController.text = _emailController.text.trim();
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_reset_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Reset Password',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Form(
                key: resetFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter your registered email. We will send you a '
                          'password reset link.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: resetEmailController,
                      enabled: !isLoading,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        hintText: 'Enter your email',
                        prefixIcon: const Icon(Icons.email_outlined, size: 20),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(email)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                    if (!(resetFormKey.currentState?.validate() ??
                        false)) {
                      return;
                    }

                    setState(() => isLoading = true);

                    final email =
                    resetEmailController.text.trim();

                    try {
                      await FirebaseAuth.instance
                          .sendPasswordResetEmail(email: email);

                      if (!dialogContext.mounted) return;

                      Navigator.of(dialogContext).pop();

                      _showSuccess(
                        'Password reset link sent to $email',
                      );
                    } on FirebaseAuthException catch (e) {
                      setState(() => isLoading = false);

                      String errorMsg;
                      switch (e.code) {
                        case 'user-not-found':
                          errorMsg =
                          'No account found with this email';
                          break;
                        case 'invalid-email':
                          errorMsg = 'Invalid email address';
                          break;
                        case 'too-many-requests':
                          errorMsg =
                          'Too many attempts. Try again later';
                          break;
                        default:
                          errorMsg =
                          'Error: ${e.message ?? e.code}';
                      }

                      if (!dialogContext.mounted) return;
                      ScaffoldMessenger.of(dialogContext)
                          .showSnackBar(
                        SnackBar(
                          content: Text(errorMsg),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } catch (e) {
                      setState(() => isLoading = false);

                      if (!dialogContext.mounted) return;
                      ScaffoldMessenger.of(dialogContext)
                          .showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  )
                      : const Text(
                    'Send Reset Link',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    resetEmailController.dispose();
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 21),
      suffixIcon: suffixIcon,
      isDense: true,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  Widget _buildBrand({required bool compact}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(compact ? 10 : 15),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.school_rounded,
            size: compact ? 32 : 46,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: compact ? 8 : 14),
        Text(
          'Welcome Back',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: compact ? 23 : 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Sign in to continue',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: compact ? 12 : 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      focusNode: _emailFocus,
      enabled: true,
      readOnly: false,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      autocorrect: false,
      style: const TextStyle(fontSize: 14),
      decoration: _inputDecoration(
        label: 'Email Address',
        hint: 'Enter your email',
        icon: Icons.email_outlined,
      ),
      onFieldSubmitted: (_) {
        _passwordFocus.requestFocus();
      },
      validator: (value) {
        final email = value?.trim() ?? '';

        if (email.isEmpty) {
          return 'Please enter your email';
        }

        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
          return 'Please enter a valid email';
        }

        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      focusNode: _passwordFocus,
      enabled: true,
      readOnly: false,
      obscureText: _obscurePassword,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.password],
      style: const TextStyle(fontSize: 14),
      decoration: _inputDecoration(
        label: 'Password',
        hint: 'Enter your password',
        icon: Icons.lock_outline,
        suffixIcon: IconButton(
          tooltip: _obscurePassword ? 'Show password' : 'Hide password',
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 21,
          ),
        ),
      ),
      onFieldSubmitted: (_) => _login(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }

        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }

        return null;
      },
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _showForgotPasswordDialog,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          minimumSize: const Size(0, 36),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'Forgot Password?',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }

  Widget _buildSignupLink({required bool compact}) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          "Don't have an account?",
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: compact ? 12 : 13,
          ),
        ),
        TextButton(
          onPressed: () {
            FocusScope.of(context).unfocus();

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const SignupScreen(),
              ),
            );
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: const Size(44, 40),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Sign Up',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 13 : 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard({
    required bool compact,
    required bool loading,
  }) {
    final gap = compact ? 12.0 : 16.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 18 : 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8EDF3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBrand(compact: compact),

            SizedBox(height: compact ? 22 : 30),

            _buildEmailField(),

            SizedBox(height: gap),

            _buildPasswordField(),

            _buildForgotPassword(),

            SizedBox(height: compact ? 10 : 16),

            CustomButton(
              text: 'Login',
              onPressed: loading ? null : _login,
              isLoading: loading,
            ),

            SizedBox(height: gap),

            _buildDivider(),

            SizedBox(height: gap),

            CustomButton(
              text: 'Continue with Google',
              onPressed: loading ? null : _googleLogin,
              isOutlined: true,
              icon: Icons.g_mobiledata,
            ),

            SizedBox(height: compact ? 10 : 16),

            _buildSignupLink(compact: compact),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            final compact = height < 650;
            final tiny = height < 420;

            final horizontalPadding =
            width < 360 ? 14.0 : width < 600 ? 22.0 : 32.0;

            return Scrollbar(
              thumbVisibility: false,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: tiny ? 8 : compact ? 14 : 28,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                    (height - (tiny ? 16 : compact ? 28 : 56))
                        .clamp(0.0, double.infinity),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: _buildLoginCard(
                        compact: compact,
                        loading: authProvider.isLoading,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}