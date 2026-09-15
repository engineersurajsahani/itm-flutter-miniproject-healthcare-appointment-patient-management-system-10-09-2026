import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/healthcare_repository.dart';
import '../../../models/appointment.dart';
import 'dashboard_widgets.dart';

class PatientDashboard extends StatelessWidget {
  const PatientDashboard({
    required this.selectedTab,
    required this.appointments,
    required this.onBook,
    required this.onCancelAppointment,
    super.key,
  });

  final int selectedTab;
  final List<Appointment> appointments;
  final VoidCallback onBook;
  final ValueChanged<String> onCancelAppointment;

  @override
  Widget build(BuildContext context) {
    switch (selectedTab) {
      case 1:
        return _buildMyAppointments(context);
      case 2:
        return _buildCareTeam(context);
      case 3:
        return _buildHealthRecords(context);
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
          title: 'Quick Actions',
          action: 'Schedule Visit',
          child: Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.calendar_month_outlined,
                  title: 'Book Appointment',
                  subtitle: 'Choose a doctor & time slot',
                  color: AppColors.blue,
                  onTap: onBook,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.medication_liquid_outlined,
                  title: 'Request Refill',
                  subtitle: 'Active prescriptions ready',
                  color: const Color(0xFF67B99A),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Prescription refill request sent to pharmacy.')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.contact_support_outlined,
                  title: 'Virtual Consult',
                  subtitle: 'Talk with on-call nurse',
                  color: const Color(0xFF9B83DF),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Connecting to virtual triage support...')),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        DashboardPanel(
          title: 'Your Upcoming Appointments',
          action: 'Book New',
          child: appointments.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No upcoming appointments. Book one to get started!'),
                )
              : Column(
                  children: appointments.map((apt) => AppointmentTile(appointment: apt)).toList(),
                ),
        ),
        const SizedBox(height: 24),
        DashboardPanel(
          title: 'Recommended Doctors',
          action: 'View All Care Team',
          child: Column(
            children: HealthcareRepository.getDoctors().take(3).map((doctor) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: doctor.avatarColor.withAlpha(35),
                      child: Text(
                        doctor.name.split(' ').last[0],
                        style: TextStyle(color: doctor.avatarColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(doctor.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('${doctor.specialty} • ${doctor.experience}', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(doctor.rating.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: onBook,
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                          child: const Text('Book', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMyAppointments(BuildContext context) {
    return DashboardPanel(
      title: 'My Booked Appointments (${appointments.length})',
      action: 'Book New',
      child: Column(
        children: [
          if (appointments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Text('You have no booked appointments at the moment.'),
            ),
          for (final apt in appointments)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lavender.withAlpha(80),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: apt.color.withAlpha(45),
                    child: Icon(Icons.calendar_today, color: apt.color, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(apt.doctor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.ink)),
                        const SizedBox(height: 3),
                        Text('${apt.specialty} • ${apt.date}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                        if (apt.notes.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text('Notes: ${apt.notes}', style: const TextStyle(color: AppColors.ink, fontSize: 11, fontStyle: FontStyle.italic)),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: apt.status == 'Confirmed'
                              ? Colors.green.withAlpha(35)
                              : Colors.orange.withAlpha(35),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          apt.status,
                          style: TextStyle(
                            color: apt.status == 'Confirmed' ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => onCancelAppointment(apt.id),
                        child: const Text('Cancel Visit', style: TextStyle(color: Colors.redAccent, fontSize: 11)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCareTeam(BuildContext context) {
    final doctors = HealthcareRepository.getDoctors();
    return DashboardPanel(
      title: 'Your Care Team',
      action: '${doctors.length} Specialists Available',
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: doctors.length,
        separatorBuilder: (_, _) => const Divider(color: AppColors.line),
        itemBuilder: (context, index) {
          final doc = doctors[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: doc.avatarColor.withAlpha(45),
                  child: Text(
                    doc.name.replaceFirst('Dr. ', '')[0],
                    style: TextStyle(color: doc.avatarColor, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doc.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.ink)),
                      Text('${doc.specialty} • ${doc.experience} exp', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('Available: ${doc.availability}', style: const TextStyle(color: AppColors.blue, fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: onBook,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Book Visit'),
                  style: FilledButton.styleFrom(backgroundColor: AppColors.blue),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHealthRecords(BuildContext context) {
    return const Column(
      children: [
        DashboardPanel(
          title: 'Recent Medical Records & Prescriptions',
          action: 'Download PDF',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RecordTile(
                title: 'Cardiology ECG Report',
                date: 'May 10, 2026',
                doctor: 'Dr. Sarah Wilson',
                status: 'Normal',
              ),
              _RecordTile(
                title: 'Lisinopril 10mg Prescription',
                date: 'April 22, 2026',
                doctor: 'Dr. Sarah Wilson',
                status: 'Active (Refill Available)',
              ),
              _RecordTile(
                title: 'Comprehensive Blood Panel',
                date: 'March 15, 2026',
                doctor: 'Dr. Emily Davis',
                status: 'Completed',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
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

class _RecordTile extends StatelessWidget {
  const _RecordTile({
    required this.title,
    required this.date,
    required this.doctor,
    required this.status,
  });

  final String title;
  final String date;
  final String doctor;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          const Icon(Icons.description_outlined, color: AppColors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text('$doctor • $date', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.lavender,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(status, style: const TextStyle(color: AppColors.blue, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
