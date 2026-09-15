import 'package:flutter/material.dart';

class Doctor {
  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.email,
    required this.phone,
    required this.rating,
    required this.experience,
    required this.availability,
    required this.avatarColor,
  });

  final String id;
  final String name;
  final String specialty;
  final String email;
  final String phone;
  final double rating;
  final String experience;
  final String availability;
  final Color avatarColor;

  Map<String, dynamic> toMap() => {
    'name': name,
    'specialty': specialty,
    'email': email,
    'phone': phone,
    'rating': rating,
    'experience': experience,
    'availability': availability,
  };

  factory Doctor.fromMap(String id, Map<String, dynamic> map) => Doctor(
    id: id,
    name: map['name'] ?? 'Doctor',
    specialty: map['specialty'] ?? 'General Medicine',
    email: map['email'] ?? '',
    phone: map['phone'] ?? '',
    rating: (map['rating'] as num?)?.toDouble() ?? 4.8,
    experience: map['experience'] ?? '5 years',
    availability: map['availability'] ?? 'Mon - Fri',
    avatarColor: const Color(0xFF6D9FEF),
  );
}
