import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../firebase_options.dart';
import '../models/appointment.dart';
import '../models/doctor.dart';
import '../models/patient_record.dart';
import '../models/user_role.dart';

class HealthcareRepository {
  HealthcareRepository._();

  static bool firebaseReady = false;

  // In-memory fallback lists for seamless offline & prototype performance
  static final List<Appointment> _appointments = [
    const Appointment(
      id: 'apt-1',
      patient: 'Olivia Bennett',
      doctor: 'Dr. Sarah Wilson',
      specialty: 'Cardiology',
      date: 'Today, 09:30 AM',
      time: '09:30 AM',
      status: 'Confirmed',
      color: Color(0xFFEF8B6D),
      notes: 'Routine ECG and blood pressure review',
    ),
    const Appointment(
      id: 'apt-2',
      patient: 'Noah Williams',
      doctor: 'Dr. Michael Chen',
      specialty: 'Dermatology',
      date: 'Today, 11:00 AM',
      time: '11:00 AM',
      status: 'Confirmed',
      color: Color(0xFF6D9FEF),
      notes: 'Annual skin screening checkup',
    ),
    const Appointment(
      id: 'apt-3',
      patient: 'Emma Thompson',
      doctor: 'Dr. Emily Davis',
      specialty: 'Pediatrics',
      date: 'Today, 02:15 PM',
      time: '02:15 PM',
      status: 'Pending',
      color: Color(0xFF9B83DF),
      notes: 'Follow up on child vaccination schedule',
    ),
    const Appointment(
      id: 'apt-4',
      patient: 'James Anderson',
      doctor: 'Dr. Robert Taylor',
      specialty: 'Neurology',
      date: 'Tomorrow, 10:00 AM',
      time: '10:00 AM',
      status: 'Confirmed',
      color: Color(0xFF67B99A),
      notes: 'Migraine consultation & prescription review',
    ),
  ];

  static final List<Doctor> _doctors = [
    const Doctor(
      id: 'doc-1',
      name: 'Dr. Sarah Wilson',
      specialty: 'Cardiology',
      email: 'sarah.wilson@careflow.com',
      phone: '+1 (555) 234-5678',
      rating: 4.9,
      experience: '12 years',
      availability: 'Mon, Wed, Fri',
      avatarColor: Color(0xFFEF8B6D),
    ),
    const Doctor(
      id: 'doc-2',
      name: 'Dr. Michael Chen',
      specialty: 'Dermatology',
      email: 'michael.chen@careflow.com',
      phone: '+1 (555) 345-6789',
      rating: 4.8,
      experience: '9 years',
      availability: 'Tue, Thu, Sat',
      avatarColor: Color(0xFF6D9FEF),
    ),
    const Doctor(
      id: 'doc-3',
      name: 'Dr. Emily Davis',
      specialty: 'Pediatrics',
      email: 'emily.davis@careflow.com',
      phone: '+1 (555) 456-7890',
      rating: 4.95,
      experience: '15 years',
      availability: 'Mon - Fri',
      avatarColor: Color(0xFF9B83DF),
    ),
    const Doctor(
      id: 'doc-4',
      name: 'Dr. Robert Taylor',
      specialty: 'Neurology',
      email: 'robert.taylor@careflow.com',
      phone: '+1 (555) 567-8901',
      rating: 4.7,
      experience: '8 years',
      availability: 'Mon, Tue, Thu',
      avatarColor: Color(0xFF67B99A),
    ),
  ];

  static final List<PatientRecord> _patients = [
    const PatientRecord(
      id: 'pat-1',
      name: 'Olivia Bennett',
      age: 34,
      gender: 'Female',
      email: 'olivia.b@gmail.com',
      phone: '+1 (555) 111-2222',
      bloodGroup: 'A+',
      lastVisit: 'Today',
      condition: 'Hypertension - Stable',
      prescriptions: ['Lisinopril 10mg', 'Multivitamins'],
    ),
    const PatientRecord(
      id: 'pat-2',
      name: 'Noah Williams',
      age: 28,
      gender: 'Male',
      email: 'noah.w@gmail.com',
      phone: '+1 (555) 222-3333',
      bloodGroup: 'O+',
      lastVisit: 'Today',
      condition: 'Eczema - Improving',
      prescriptions: ['Hydrocortisone Cream 1%'],
    ),
    const PatientRecord(
      id: 'pat-3',
      name: 'Emma Thompson',
      age: 8,
      gender: 'Female',
      email: 'emma.t@gmail.com',
      phone: '+1 (555) 333-4444',
      bloodGroup: 'B+',
      lastVisit: 'May 12, 2026',
      condition: 'Pediatric Checkup - Healthy',
      prescriptions: ['Vitamin D3 Drops'],
    ),
    const PatientRecord(
      id: 'pat-4',
      name: 'James Anderson',
      age: 45,
      gender: 'Male',
      email: 'james.a@gmail.com',
      phone: '+1 (555) 444-5555',
      bloodGroup: 'AB+',
      lastVisit: 'Apr 28, 2026',
      condition: 'Chronic Migraine - In Treatment',
      prescriptions: ['Sumatriptan 50mg', 'Magnesium 400mg'],
    ),
  ];

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      firebaseReady = true;
    } catch (_) {
      firebaseReady = false;
    }
  }

  static Future<UserRole> signIn({
    required String email,
    required String password,
    required UserRole selectedRole,
  }) async {
    if (firebaseReady) {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      try {
        final userDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid);
        final profile = await userDoc.get();

        if (!profile.exists || profile.data()?['role'] == null) {
          await userDoc.set({
            'email': email,
            'role': selectedRole.name,
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          return selectedRole;
        }

        final roleStr = profile.data()?['role'] as String?;
        final savedRole = UserRole.values.firstWhere(
          (item) => item.name == roleStr,
          orElse: () => selectedRole,
        );

        return selectedRole != UserRole.patient ? selectedRole : savedRole;
      } catch (e) {
        debugPrint('Firestore read error during signIn: $e');
        return selectedRole;
      }
    }

    return selectedRole;
  }

  static Future<UserRole> signInWithGoogle({
    required UserRole selectedRole,
  }) async {
    if (!firebaseReady) return selectedRole;

    final credential = await FirebaseAuth.instance.signInWithProvider(
      GoogleAuthProvider(),
    );
    try {
      final userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid);
      final profile = await userDoc.get();

      if (!profile.exists || profile.data()?['role'] == null) {
        await userDoc.set({
          'email': credential.user?.email,
          'displayName': credential.user?.displayName,
          'role': selectedRole.name,
          'createdAt': FieldValue.serverTimestamp(),
        });
        return selectedRole;
      }

      final roleStr = profile.data()?['role'] as String?;
      final savedRole = UserRole.values.firstWhere(
        (item) => item.name == roleStr,
        orElse: () => selectedRole,
      );
      return selectedRole != UserRole.patient ? selectedRole : savedRole;
    } catch (e) {
      debugPrint('Firestore read/write error during Google sign in: $e');
      return selectedRole;
    }
  }

  static Future<void> createUserAccount({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    if (!firebaseReady) return;

    final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
            'email': email,
            'role': role.name,
            'createdAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      debugPrint('Firestore write error during account creation: $e');
    }
  }

  static Future<void> createPatientAccount({
    required String email,
    required String password,
  }) async {
    await createUserAccount(email: email, password: password, role: UserRole.patient);
  }

  static Future<void> signOut() async {
    if (firebaseReady) await FirebaseAuth.instance.signOut();
  }

  // --- APPOINTMENTS ---
  static List<Appointment> getAppointments() => List.unmodifiable(_appointments);

  static Future<void> saveAppointment(Appointment appointment) async {
    _appointments.insert(0, appointment);
    if (!firebaseReady) return;

    try {
      await FirebaseFirestore.instance.collection('appointments').add({
        'patient': appointment.patient,
        'doctor': appointment.doctor,
        'specialty': appointment.specialty,
        'date': appointment.date,
        'time': appointment.time,
        'status': appointment.status,
        'notes': appointment.notes,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Firestore write error during saveAppointment: $e');
    }
  }

  static Future<void> updateAppointmentStatus(String id, String newStatus) async {
    final index = _appointments.indexWhere((a) => a.id == id);
    if (index != -1) {
      _appointments[index] = _appointments[index].copyWith(status: newStatus);
    }
    if (!firebaseReady) return;

    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(id)
          .set({'status': newStatus}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore update error: $e');
    }
  }

  // --- DOCTORS ---
  static List<Doctor> getDoctors() => List.unmodifiable(_doctors);

  static Future<void> addDoctor(Doctor doctor) async {
    _doctors.insert(0, doctor);
    if (!firebaseReady) return;

    try {
      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(doctor.id)
          .set(doctor.toMap());
    } catch (e) {
      debugPrint('Firestore doctor write error: $e');
    }
  }

  // --- PATIENTS ---
  static List<PatientRecord> getPatients() => List.unmodifiable(_patients);

  static Future<void> addPatient(PatientRecord patient) async {
    _patients.insert(0, patient);
    if (!firebaseReady) return;

    try {
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(patient.id)
          .set(patient.toMap());
    } catch (e) {
      debugPrint('Firestore patient write error: $e');
    }
  }
}
