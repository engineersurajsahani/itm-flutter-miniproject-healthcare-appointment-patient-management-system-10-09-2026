import 'package:flutter/material.dart';

class Appointment {
  const Appointment({
    required this.id,
    required this.patient,
    required this.doctor,
    required this.specialty,
    required this.date,
    required this.time,
    required this.status,
    required this.color,
    this.notes = '',
  });

  final String id;
  final String patient;
  final String doctor;
  final String specialty;
  final String date;
  final String time;
  final String status; // 'Confirmed', 'Pending', 'Completed', 'Cancelled'
  final Color color;
  final String notes;

  Appointment copyWith({
    String? id,
    String? patient,
    String? doctor,
    String? specialty,
    String? date,
    String? time,
    String? status,
    Color? color,
    String? notes,
  }) {
    return Appointment(
      id: id ?? this.id,
      patient: patient ?? this.patient,
      doctor: doctor ?? this.doctor,
      specialty: specialty ?? this.specialty,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      color: color ?? this.color,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patient': patient,
      'doctor': doctor,
      'specialty': specialty,
      'date': date,
      'time': time,
      'status': status,
      'notes': notes,
    };
  }

  factory Appointment.fromMap(String id, Map<String, dynamic> map) {
    return Appointment(
      id: id,
      patient: map['patient'] ?? 'Unknown Patient',
      doctor: map['doctor'] ?? 'Dr. Staff',
      specialty: map['specialty'] ?? 'General Medicine',
      date: map['date'] ?? 'Today',
      time: map['time'] ?? '09:00 AM',
      status: map['status'] ?? 'Pending',
      color: const Color(0xFF6D9FEF),
      notes: map['notes'] ?? '',
    );
  }
}
