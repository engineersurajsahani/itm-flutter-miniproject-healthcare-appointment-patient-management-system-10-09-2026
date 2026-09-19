import 'package:flutter/material.dart';

import 'core/theme/app_colors.dart';
import 'data/healthcare_repository.dart';
import 'features/dashboard/dashboard_page.dart';
import 'features/auth/login_page.dart';
import 'models/user_role.dart';

class HealthcareApp extends StatelessWidget {
  const HealthcareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Careflow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.blue),
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Avenir',
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  UserRole? _role;

  @override
  Widget build(BuildContext context) {
    if (_role == null) {
      return LoginPage(onSignedIn: (role) => setState(() => _role = role));
    }
    return DashboardPage(
      role: _role!,
      onSignOut: () async {
        await HealthcareRepository.signOut();
        if (mounted) setState(() => _role = null);
      },
    );
  }
}
