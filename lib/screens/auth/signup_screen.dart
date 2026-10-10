import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../home/home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _studentIdController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _studentIdFocus = FocusNode();

  bool _obscurePassword = true;
  String _selectedDepartment = 'Computer Science';

  final List<String> _departments = [
    'Computer Science',
    'Software Engineering',
    'Electrical Engineering',
    'Business Administration',
    'Mathematics',
    'Physics',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _studentIdController.dispose();

    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _studentIdFocus.dispose();

    super.dispose();
  }

  Future<void> _signup() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final authProvider =
    Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signUp(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: 'student',
      studentId: _studentIdController.text.trim(),
      department: _selectedDepartment,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Signup failed'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  InputDecoration _decoration({
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
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  Widget _buildFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _nameController,
          focusNode: _nameFocus,
          enabled: true,
          readOnly: false,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.name],
          style: const TextStyle(fontSize: 14),
          decoration: _decoration(
            label: 'Full Name',
            hint: 'Enter your full name',
            icon: Icons.person_outline,
          ),
          onFieldSubmitted: (_) {
            _emailFocus.requestFocus();
          },
          validator: (value) {
            final name = value?.trim() ?? '';

            if (name.isEmpty) {
              return 'Please enter your full name';
            }

            if (name.length < 2) {
              return 'Name must contain at least 2 characters';
            }

            return null;
          },
        ),

        const SizedBox(height: 16),

        TextFormField(
          controller: _emailController,
          focusNode: _emailFocus,
          enabled: true,
          readOnly: false,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          autocorrect: false,
          style: const TextStyle(fontSize: 14),
          decoration: _decoration(
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
        ),

        const SizedBox(height: 16),

        TextFormField(
          controller: _passwordController,
          focusNode: _passwordFocus,
          enabled: true,
          readOnly: false,
          obscureText: _obscurePassword,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
          enableSuggestions: false,
          autocorrect: false,
          style: const TextStyle(fontSize: 14),
          decoration: _decoration(
            label: 'Password',
            hint: 'Create a password',
            icon: Icons.lock_outline,
            suffixIcon: IconButton(
              tooltip:
              _obscurePassword ? 'Show password' : 'Hide password',
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
          onFieldSubmitted: (_) {
            _studentIdFocus.requestFocus();
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }

            if (value.length < 6) {
              return 'Password must contain at least 6 characters';
            }

            return null;
          },
        ),

        const SizedBox(height: 16),

        TextFormField(
          controller: _studentIdController,
          focusNode: _studentIdFocus,
          enabled: true,
          readOnly: false,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          style: const TextStyle(fontSize: 14),
          decoration: _decoration(
            label: 'Student ID',
            hint: 'Enter your student ID',
            icon: Icons.badge_outlined,
          ),
          onFieldSubmitted: (_) {
            FocusScope.of(context).unfocus();
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your student ID';
            }

            return null;
          },
        ),

        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          initialValue: _selectedDepartment,
          isExpanded: true,
          menuMaxHeight: 280,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          decoration: _decoration(
            label: 'Department',
            hint: 'Select department',
            icon: Icons.school_outlined,
          ),
          items: _departments.map((department) {
            return DropdownMenuItem<String>(
              value: department,
              child: Text(
                department,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedDepartment = value;
              });
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,

      appBar: AppBar(
        title: const Text(
          'Create Account',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 600;
            final tiny = constraints.maxHeight < 400;

            return Scrollbar(
              thumbVisibility: false,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth < 360 ? 16 : 24,
                  vertical: compact ? 12 : 24,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!tiny) ...[
                            Icon(
                              Icons.school_rounded,
                              size: compact ? 34 : 46,
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Create Your Account',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: compact ? 21 : 26,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Sign up to get started',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: compact ? 12 : 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: compact ? 18 : 26),
                          ],

                          _buildFields(),

                          SizedBox(height: compact ? 18 : 24),

                          CustomButton(
                            text: 'Sign Up',
                            isLoading: authProvider.isLoading,
                            onPressed: authProvider.isLoading
                                ? null
                                : _signup,
                          ),

                          const SizedBox(height: 16),

                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Text(
                                'Already have an account?',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  'Login',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),
                        ],
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