import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/healthcare_repository.dart';
import '../../models/appointment.dart';
import '../../models/doctor.dart';
import '../../models/patient_record.dart';
import '../../models/user_role.dart';
import 'widgets/admin_dashboard.dart';
import 'widgets/dashboard_widgets.dart';
import 'widgets/doctor_dashboard.dart';
import 'widgets/patient_dashboard.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({required this.role, required this.onSignOut, super.key});

  final UserRole role;
  final VoidCallback onSignOut;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedNav = 0;
  late List<Appointment> _appointments;

  @override
  void initState() {
    super.initState();
    _appointments = List.from(HealthcareRepository.getAppointments());
  }

  void _onSelectTab(int index) {
    setState(() => _selectedNav = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: DashboardSidebar(
          role: widget.role,
          selected: _selectedNav,
          onSelect: (value) {
            Navigator.pop(context); // close drawer
            _onSelectTab(value);
          },
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 900;
            return Row(
              children: [
                if (!compact)
                  DashboardSidebar(
                    role: widget.role,
                    selected: _selectedNav,
                    onSelect: _onSelectTab,
                  ),
                Expanded(child: _content(compact)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _content(bool compact) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        compact ? 20 : 40,
        28,
        compact ? 20 : 40,
        40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardTopBar(
            compact: compact,
            role: widget.role,
            onBook: _showBookingDialog,
            onSignOut: widget.onSignOut,
          ),
          const SizedBox(height: 28),
          Text(
            widget.role.greeting,
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w800, color: AppColors.ink),
          ),
          const SizedBox(height: 6),
          Text(
            _getTabSubheading(),
            style: const TextStyle(color: AppColors.muted, fontSize: 15),
          ),
          const SizedBox(height: 24),
          StatsGrid(compact: compact, role: widget.role),
          const SizedBox(height: 28),
          if (widget.role == UserRole.patient)
            PatientDashboard(
              selectedTab: _selectedNav,
              appointments: _appointments,
              onBook: _showBookingDialog,
              onCancelAppointment: _cancelAppointment,
            )
          else if (widget.role == UserRole.doctor)
            DoctorDashboard(
              selectedTab: _selectedNav,
              appointments: _appointments,
              onUpdateStatus: _updateAppointmentStatus,
              onAddNote: _showAddNoteDialog,
            )
          else if (widget.role == UserRole.admin)
            AdminDashboard(
              selectedTab: _selectedNav,
              onAddDoctor: _showAddDoctorDialog,
              onAddPatient: _showAddPatientDialog,
            ),
        ],
      ),
    );
  }

  String _getTabSubheading() {
    switch (widget.role) {
      case UserRole.patient:
        return 'Manage your upcoming visits, care team, and health records.';
      case UserRole.doctor:
        return 'Review your clinical queue, patient charts, and appointments.';
      case UserRole.admin:
        return 'Overview of hospital operations, staff directory, and platform analytics.';
    }
  }

  // --- ACTIONS ---

  void _cancelAppointment(String id) {
    setState(() {
      _appointments.removeWhere((a) => a.id == id);
    });
    HealthcareRepository.updateAppointmentStatus(id, 'Cancelled');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Appointment cancelled')),
    );
  }

  void _updateAppointmentStatus(String id, String newStatus) {
    setState(() {
      final index = _appointments.indexWhere((a) => a.id == id);
      if (index != -1) {
        _appointments[index] = _appointments[index].copyWith(status: newStatus);
      }
    });
    HealthcareRepository.updateAppointmentStatus(id, newStatus);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Appointment status updated to $newStatus')),
    );
  }

  Future<void> _showBookingDialog() async {
    final patientController = TextEditingController(text: 'Olivia Bennett');
    final doctors = HealthcareRepository.getDoctors();
    String selectedDoctor = doctors.first.name;
    String selectedSpecialty = doctors.first.specialty;
    final notesController = TextEditingController();
    String selectedTime = '04:00 PM';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Book an Appointment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: patientController,
                decoration: const InputDecoration(labelText: 'Patient Name'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedDoctor,
                decoration: const InputDecoration(labelText: 'Select Doctor'),
                items: doctors.map((doc) => DropdownMenuItem(
                  value: doc.name,
                  child: Text('${doc.name} (${doc.specialty})'),
                )).toList(),
                onChanged: (val) {
                  if (val != null) {
                    selectedDoctor = val;
                    selectedSpecialty = doctors.firstWhere((d) => d.name == val).specialty;
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedTime,
                decoration: const InputDecoration(labelText: 'Preferred Time'),
                items: const [
                  DropdownMenuItem(value: '09:00 AM', child: Text('09:00 AM')),
                  DropdownMenuItem(value: '11:30 AM', child: Text('11:30 AM')),
                  DropdownMenuItem(value: '02:00 PM', child: Text('02:00 PM')),
                  DropdownMenuItem(value: '04:00 PM', child: Text('04:00 PM')),
                ],
                onChanged: (val) => selectedTime = val ?? '04:00 PM',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Reason for visit / symptoms',
                  hintText: 'e.g. Annual checkup or chest pain',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.blue),
            child: const Text('Confirm Booking'),
          ),
        ],
      ),
    );

    if (result != true || !mounted) return;

    final appointment = Appointment(
      id: 'apt-${DateTime.now().millisecondsSinceEpoch}',
      patient: patientController.text.trim().isEmpty ? 'Patient' : patientController.text.trim(),
      doctor: selectedDoctor,
      specialty: selectedSpecialty,
      date: 'Today, $selectedTime',
      time: selectedTime,
      status: 'Pending',
      color: const Color(0xFF67B99A),
      notes: notesController.text.trim(),
    );

    setState(() => _appointments.insert(0, appointment));
    await HealthcareRepository.saveAppointment(appointment);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment booked successfully!')),
      );
    }
  }

  Future<void> _showAddNoteDialog(PatientRecord patient) async {
    final noteController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Note for ${patient.name}'),
        content: TextField(
          controller: noteController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Clinical Note / Prescription',
            hintText: 'Enter symptoms, diagnosis, or prescribed medicine...',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.blue),
            child: const Text('Save Note'),
          ),
        ],
      ),
    );

    if (result == true && noteController.text.trim().isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Note added to ${patient.name}\'s record.')),
      );
    }
  }

  Future<void> _showAddDoctorDialog() async {
    final nameController = TextEditingController();
    final specialtyController = TextEditingController(text: 'General Medicine');
    final emailController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Doctor to Staff'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Doctor Name (e.g. Dr. John Doe)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: specialtyController,
              decoration: const InputDecoration(labelText: 'Specialty'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email Address'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.blue),
            child: const Text('Register Doctor'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.trim().isNotEmpty && mounted) {
      final doc = Doctor(
        id: 'doc-${DateTime.now().millisecondsSinceEpoch}',
        name: nameController.text.trim().startsWith('Dr.') ? nameController.text.trim() : 'Dr. ${nameController.text.trim()}',
        specialty: specialtyController.text.trim(),
        email: emailController.text.trim().isEmpty ? 'doctor@careflow.com' : emailController.text.trim(),
        phone: '+1 (555) 999-0000',
        rating: 5.0,
        experience: '1 year',
        availability: 'Mon - Fri',
        avatarColor: const Color(0xFF6D9FEF),
      );
      await HealthcareRepository.addDoctor(doc);
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${doc.name} added to hospital staff.')),
        );
      }
    }
  }

  Future<void> _showAddPatientDialog() async {
    final nameController = TextEditingController();
    final ageController = TextEditingController(text: '30');
    final genderController = TextEditingController(text: 'Female');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Register New Patient'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Patient Full Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Age'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: genderController,
              decoration: const InputDecoration(labelText: 'Gender'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.blue),
            child: const Text('Save Patient'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.trim().isNotEmpty && mounted) {
      final patient = PatientRecord(
        id: 'pat-${DateTime.now().millisecondsSinceEpoch}',
        name: nameController.text.trim(),
        age: int.tryParse(ageController.text.trim()) ?? 30,
        gender: genderController.text.trim(),
        email: '${nameController.text.trim().toLowerCase().replaceAll(' ', '.')}@gmail.com',
        phone: '+1 (555) 777-8888',
        bloodGroup: 'O+',
        lastVisit: 'Today',
        condition: 'General Checkup',
      );
      await HealthcareRepository.addPatient(patient);
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Patient ${patient.name} registered.')),
        );
      }
    }
  }
}
