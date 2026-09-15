import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/healthcare_repository.dart';
import 'dashboard_widgets.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({
    required this.selectedTab,
    required this.onAddDoctor,
    required this.onAddPatient,
    super.key,
  });

  final int selectedTab;
  final VoidCallback onAddDoctor;
  final VoidCallback onAddPatient;

  @override
  Widget build(BuildContext context) {
    switch (selectedTab) {
      case 1:
        return _buildPatientsTab(context);
      case 2:
        return _buildDoctorsTab(context);
      case 3:
        return _buildReportsTab(context);
      case 0:
      default:
        return _buildOverview(context);
    }
  }

  Widget _buildOverview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardPanel(
          title: 'Administrative Control Center',
          action: 'System Status: Optimal',
          child: Row(
            children: [
              Expanded(
                child: _AdminActionTile(
                  icon: Icons.person_add_alt_1_outlined,
                  title: 'Add New Doctor',
                  subtitle: 'Register medical staff & specialty',
                  color: AppColors.blue,
                  onTap: onAddDoctor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _AdminActionTile(
                  icon: Icons.badge_outlined,
                  title: 'Register Patient',
                  subtitle: 'Create patient record in system',
                  color: const Color(0xFF67B99A),
                  onTap: onAddPatient,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _AdminActionTile(
                  icon: Icons.shield_outlined,
                  title: 'Security Audit',
                  subtitle: 'HIPAA & Access permissions',
                  color: const Color(0xFF9B83DF),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Security audit log generated.')),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: DashboardPanel(
                title: 'System Activity Stream',
                action: 'Live Feed',
                child: const Column(
                  children: [
                    _LogItem(time: '10 mins ago', message: 'Dr. Sarah Wilson updated patient record #PAT-1'),
                    _LogItem(time: '25 mins ago', message: 'New appointment booked for Cardiology clinic'),
                    _LogItem(time: '1 hour ago', message: 'System automated backup completed successfully'),
                    _LogItem(time: '2 hours ago', message: 'New patient Noah Williams registered via Web App'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 2,
              child: DashboardPanel(
                title: 'Quick Operations',
                action: 'Control',
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: onAddDoctor,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Doctor'),
                        style: FilledButton.styleFrom(backgroundColor: AppColors.blue),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: onAddPatient,
                        icon: const Icon(Icons.person_add_alt),
                        label: const Text('Add Patient'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPatientsTab(BuildContext context) {
    final patients = HealthcareRepository.getPatients();
    return DashboardPanel(
      title: 'Global Patient Records (${patients.length})',
      action: 'Register Patient',
      child: Column(
        children: [
          Row(
            children: [
              const Spacer(),
              FilledButton.icon(
                onPressed: onAddPatient,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Patient'),
                style: FilledButton.styleFrom(backgroundColor: AppColors.blue),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: patients.length,
            separatorBuilder: (_, _) => const Divider(color: AppColors.line),
            itemBuilder: (context, index) {
              final pat = patients[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.blue.withAlpha(25),
                  child: Text(pat.name[0], style: const TextStyle(color: AppColors.blue, fontWeight: FontWeight.bold)),
                ),
                title: Text(pat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${pat.gender}, ${pat.age} yrs • Blood: ${pat.bloodGroup} • ${pat.email}'),
                trailing: Chip(
                  label: Text(pat.condition, style: const TextStyle(fontSize: 11)),
                  backgroundColor: AppColors.lavender,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorsTab(BuildContext context) {
    final doctors = HealthcareRepository.getDoctors();
    return DashboardPanel(
      title: 'Medical Staff & Faculty (${doctors.length})',
      action: 'Add Staff',
      child: Column(
        children: [
          Row(
            children: [
              const Spacer(),
              FilledButton.icon(
                onPressed: onAddDoctor,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Doctor'),
                style: FilledButton.styleFrom(backgroundColor: AppColors.blue),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: doctors.length,
            separatorBuilder: (_, _) => const Divider(color: AppColors.line),
            itemBuilder: (context, index) {
              final doc = doctors[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: doc.avatarColor.withAlpha(50),
                  child: Text(doc.name.replaceFirst('Dr. ', '')[0], style: TextStyle(color: doc.avatarColor, fontWeight: FontWeight.bold)),
                ),
                title: Text(doc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${doc.specialty} • ${doc.experience} exp • ${doc.email}'),
                trailing: Text('Rating: ${doc.rating} ★', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportsTab(BuildContext context) {
    return const Column(
      children: [
        DashboardPanel(
          title: 'Site Reports & Analytics',
          action: 'Export Data',
          child: Column(
            children: [
              _ReportMetricRow(label: 'Total Platform Users', value: '1,338'),
              _ReportMetricRow(label: 'Total Appointments Handled', value: '4,289'),
              _ReportMetricRow(label: 'Average Patient Satisfaction', value: '4.9 / 5.0'),
              _ReportMetricRow(label: 'System Uptime (Last 30 days)', value: '99.98%'),
            ],
          ),
        ),
      ],
    );
  }
}

class _AdminActionTile extends StatelessWidget {
  const _AdminActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _LogItem extends StatelessWidget {
  const _LogItem({required this.time, required this.message});
  final String time;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.circle, color: AppColors.blue, size: 8),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 12, color: AppColors.ink))),
          Text(time, style: const TextStyle(fontSize: 10, color: AppColors.muted)),
        ],
      ),
    );
  }
}

class _ReportMetricRow extends StatelessWidget {
  const _ReportMetricRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.ink)),
        ],
      ),
    );
  }
}
