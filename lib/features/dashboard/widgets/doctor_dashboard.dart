import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/healthcare_repository.dart';
import '../../../models/appointment.dart';
import '../../../models/patient_record.dart';
import 'dashboard_widgets.dart';

class DoctorDashboard extends StatelessWidget {
  const DoctorDashboard({
    required this.selectedTab,
    required this.appointments,
    required this.onUpdateStatus,
    required this.onAddNote,
    super.key,
  });

  final int selectedTab;
  final List<Appointment> appointments;
  final Function(String id, String newStatus) onUpdateStatus;
  final Function(PatientRecord patient) onAddNote;

  @override
  Widget build(BuildContext context) {
    switch (selectedTab) {
      case 1:
        return _buildAppointmentsTab(context);
      case 2:
        return _buildPatientsTab(context);
      case 3:
        return _buildStaffTab(context);
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
          title: "Today's Clinical Appointments (${appointments.length})",
          action: 'Manage Schedule',
          child: Column(
            children: appointments.map((apt) => _DoctorAppointmentCard(
              appointment: apt,
              onUpdateStatus: onUpdateStatus,
            )).toList(),
          ),
        ),
        const SizedBox(height: 24),
        DashboardPanel(
          title: 'Recent Patient Activity',
          action: 'Full Directory',
          child: Column(
            children: HealthcareRepository.getPatients().take(3).map((patient) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.blue.withAlpha(25),
                      child: Text(patient.name[0], style: const TextStyle(color: AppColors.blue, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(patient.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('${patient.condition} • ${patient.gender}, ${patient.age} yrs', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => onAddNote(patient),
                      icon: const Icon(Icons.edit_note, size: 16),
                      label: const Text('Add Note', style: TextStyle(fontSize: 12)),
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

  Widget _buildAppointmentsTab(BuildContext context) {
    return DashboardPanel(
      title: 'Appointment Queue & Approvals',
      action: 'Filter',
      child: Column(
        children: [
          if (appointments.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('No appointments scheduled.'),
            ),
          for (final apt in appointments)
            _DoctorAppointmentCard(
              appointment: apt,
              onUpdateStatus: onUpdateStatus,
            ),
        ],
      ),
    );
  }

  Widget _buildPatientsTab(BuildContext context) {
    final patients = HealthcareRepository.getPatients();
    return DashboardPanel(
      title: 'Assigned Patient Records (${patients.length})',
      action: 'Search Patient',
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: patients.length,
        separatorBuilder: (_, _) => const Divider(color: AppColors.line),
        itemBuilder: (context, index) {
          final pat = patients[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.blue.withAlpha(30),
                  child: Text(pat.name[0], style: const TextStyle(color: AppColors.blue, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pat.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.ink)),
                      Text('${pat.gender}, ${pat.age} yrs • Blood Group: ${pat.bloodGroup}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('Condition: ${pat.condition}', style: const TextStyle(color: AppColors.ink, fontSize: 11, fontWeight: FontWeight.w600)),
                      if (pat.prescriptions.isNotEmpty)
                        Text('Rx: ${pat.prescriptions.join(", ")}', style: const TextStyle(color: AppColors.muted, fontSize: 11, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => onAddNote(pat),
                  icon: const Icon(Icons.edit_note, size: 16),
                  label: const Text('Add Clinical Note'),
                  style: FilledButton.styleFrom(backgroundColor: AppColors.blue),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStaffTab(BuildContext context) {
    final doctors = HealthcareRepository.getDoctors();
    return DashboardPanel(
      title: 'Medical Staff & Department Peers',
      action: 'Directory',
      child: Column(
        children: doctors.map((doc) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: doc.avatarColor.withAlpha(45),
              child: Text(doc.name.replaceFirst('Dr. ', '')[0], style: TextStyle(color: doc.avatarColor, fontWeight: FontWeight.bold)),
            ),
            title: Text(doc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${doc.specialty} • ${doc.email}'),
            trailing: Chip(label: Text(doc.availability, style: const TextStyle(fontSize: 11))),
          );
        }).toList(),
      ),
    );
  }
}

class _DoctorAppointmentCard extends StatelessWidget {
  const _DoctorAppointmentCard({
    required this.appointment,
    required this.onUpdateStatus,
  });

  final Appointment appointment;
  final Function(String id, String newStatus) onUpdateStatus;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: appointment.color.withAlpha(45),
            child: Icon(Icons.person, color: appointment.color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appointment.patient, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.ink)),
                const SizedBox(height: 2),
                Text('${appointment.specialty} • ${appointment.time}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                if (appointment.notes.isNotEmpty)
                  Text('Reason: ${appointment.notes}', style: const TextStyle(color: AppColors.ink, fontSize: 11, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: appointment.status == 'Confirmed'
                      ? Colors.green.withAlpha(35)
                      : appointment.status == 'Completed'
                          ? Colors.blue.withAlpha(35)
                          : Colors.orange.withAlpha(35),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  appointment.status,
                  style: TextStyle(
                    color: appointment.status == 'Confirmed'
                        ? Colors.green
                        : appointment.status == 'Completed'
                            ? Colors.blue
                            : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (appointment.status == 'Pending')
                    FilledButton(
                      onPressed: () => onUpdateStatus(appointment.id, 'Confirmed'),
                      style: FilledButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                      child: const Text('Approve', style: TextStyle(fontSize: 11)),
                    ),
                  if (appointment.status == 'Confirmed')
                    FilledButton(
                      onPressed: () => onUpdateStatus(appointment.id, 'Completed'),
                      style: FilledButton.styleFrom(backgroundColor: AppColors.blue, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                      child: const Text('Complete', style: TextStyle(fontSize: 11)),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
