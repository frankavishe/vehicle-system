import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_state.dart';
import '../../../shared/models/app_user.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  UserRole _role = UserRole.customer;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  String _roleWireValue(UserRole role) => switch (role) {
    UserRole.customer => 'CUSTOMER',
    UserRole.mechanic => 'MECHANIC',
    UserRole.recovery => 'RECOVERY',
    UserRole.admin => 'ADMIN', // unreachable — not offered below
  };

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref
          .read(authControllerProvider.notifier)
          .register(
            email: _email.text.trim(),
            phone: _phone.text.trim(),
            fullName: _fullName.text.trim(),
            password: _password.text,
            role: _roleWireValue(_role),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created — please log in.')),
      );
      context.go('/login');
    } on DioException catch (e) {
      setState(() => _error = _extractError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data.isNotEmpty) {
      final firstError = data.values.first;
      if (firstError is List && firstError.isNotEmpty) return firstError.first.toString();
      if (data['detail'] != null) return data['detail'].toString();
    }
    return 'Registration failed. Check your details and try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      label: 'Full name',
                      controller: _fullName,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Email',
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Phone',
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      hintText: '0712345678 or 255712345678',
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Password',
                      controller: _password,
                      obscureText: true,
                      validator: (v) => (v == null || v.length < 8) ? 'At least 8 characters' : null,
                    ),
                    const SizedBox(height: 16),
                    // Role picker restricted to SELF_SERVICE_ROLES — ADMIN
                    // is never self-service (apps/users/models.py).
                    AppDropdownField<UserRole>(
                      label: 'I am a...',
                      value: _role,
                      items: selfServiceRoles
                          .map((r) => DropdownMenuItem(value: r, child: Text(_roleLabel(r))))
                          .toList(),
                      onChanged: (v) => setState(() => _role = v!),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ],
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Create account',
                      onPressed: _loading ? null : _submit,
                      loading: _loading,
                      expand: true,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Already have an account? Log in'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _roleLabel(UserRole role) => switch (role) {
    UserRole.customer => 'Customer',
    UserRole.mechanic => 'Mechanic',
    UserRole.recovery => 'Recovery Operator',
    UserRole.admin => 'Admin',
  };
}
