import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/healthcare_repository.dart';
import '../../models/user_role.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({required this.onSignedIn, super.key});

  final ValueChanged<UserRole> onSignedIn;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _role = UserRole.patient;
  bool _loading = false;
  bool _creatingAccount = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final role = _creatingAccount
          ? await _createPatientAccount()
          : await HealthcareRepository.signIn(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              selectedRole: _role,
            );
      if (mounted) widget.onSignedIn(role);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _error = e.message ?? 'Authentication failed.');
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => _error = 'Could not sign in. Please check your credentials.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<UserRole> _createPatientAccount() async {
    await HealthcareRepository.createUserAccount(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: _role,
    );
    return _role;
  }

  Future<void> _googleSignIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final role = await HealthcareRepository.signInWithGoogle(
        selectedRole: _role,
      );
      if (mounted) widget.onSignedIn(role);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _error = e.message ?? 'Google sign-in failed.');
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Google sign-in was not completed.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Row(
                children: [
                  if (MediaQuery.sizeOf(context).width >= 760)
                    const Expanded(child: _LoginIntro()),
                  Expanded(
                    child: _LoginForm(
                      formKey: _formKey,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      role: _role,
                      loading: _loading,
                      error: _error,
                      creatingAccount: _creatingAccount,
                      onRoleChanged: (role) => setState(() => _role = role!),
                      onSubmit: _signIn,
                      onGoogleSignIn: _googleSignIn,
                      onToggleMode: () =>
                          setState(() => _creatingAccount = !_creatingAccount),
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

class _LoginIntro extends StatelessWidget {
  const _LoginIntro();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 72),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.blue,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 28),
        const Text(
          'Care that moves\nwith you.',
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 42,
            height: 1.08,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'One secure place for patients, doctors, and administrators to coordinate better healthcare.',
          style: TextStyle(color: AppColors.muted, fontSize: 16, height: 1.5),
        ),
      ],
    ),
  );
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.role,
    required this.loading,
    required this.error,
    required this.creatingAccount,
    required this.onGoogleSignIn,
    required this.onToggleMode,
    required this.onRoleChanged,
    required this.onSubmit,
  });
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final UserRole role;
  final bool loading;
  final String? error;
  final bool creatingAccount;
  final ValueChanged<UserRole?> onRoleChanged;
  final VoidCallback onSubmit;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onToggleMode;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.line),
    ),
    child: Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            creatingAccount ? 'Create your ${role.label.toLowerCase()} account' : 'Welcome back',
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Sign in to continue to your workspace.',
            style: TextStyle(color: AppColors.muted, fontSize: 13),
          ),
          const SizedBox(height: 26),
          DropdownButtonFormField<UserRole>(
            key: ValueKey(role),
            initialValue: role,
            decoration: const InputDecoration(labelText: 'I am signing in as'),
            items: UserRole.values
                .map(
                  (item) =>
                      DropdownMenuItem(value: item, child: Text(item.label)),
                )
                .toList(),
            onChanged: onRoleChanged,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email address',
              prefixIcon: Icon(Icons.mail_outline),
            ),
            validator: (value) => value == null || !value.contains('@')
                ? 'Enter a valid email'
                : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            validator: (value) => value == null || value.length < 6
                ? 'Use at least 6 characters'
                : null,
          ),
          if (error != null) ...[
            const SizedBox(height: 14),
            Text(
              error!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: loading ? null : onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.blue,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(creatingAccount ? 'Create account' : 'Sign in'),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: loading ? null : onGoogleSignIn,
              icon: const Icon(Icons.account_circle_outlined),
              label: const Text('Continue with Google'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: loading ? null : onToggleMode,
              child: Text(
                creatingAccount
                    ? 'Already have an account? Sign in'
                    : 'New patient? Create an account',
              ),
            ),
          ),
          const Center(
            child: Text(
              'Your role controls what you can access.',
              style: TextStyle(color: AppColors.muted, fontSize: 11),
            ),
          ),
        ],
      ),
    ),
  );
}
