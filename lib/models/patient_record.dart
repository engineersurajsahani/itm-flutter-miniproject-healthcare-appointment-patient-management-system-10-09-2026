class PatientRecord {
  const PatientRecord({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.email,
    required this.phone,
    required this.bloodGroup,
    required this.lastVisit,
    this.condition = 'Stable',
    this.prescriptions = const [],
  });

  final String id;
  final String name;
  final int age;
  final String gender;
  final String email;
  final String phone;
  final String bloodGroup;
  final String lastVisit;
  final String condition;
  final List<String> prescriptions;

  Map<String, dynamic> toMap() => {
    'name': name,
    'age': age,
    'gender': gender,
    'email': email,
    'phone': phone,
    'bloodGroup': bloodGroup,
    'lastVisit': lastVisit,
    'condition': condition,
    'prescriptions': prescriptions,
  };

  factory PatientRecord.fromMap(String id, Map<String, dynamic> map) => PatientRecord(
    id: id,
    name: map['name'] ?? 'Patient',
    age: map['age'] ?? 30,
    gender: map['gender'] ?? 'Other',
    email: map['email'] ?? '',
    phone: map['phone'] ?? '',
    bloodGroup: map['bloodGroup'] ?? 'O+',
    lastVisit: map['lastVisit'] ?? 'Today',
    condition: map['condition'] ?? 'Stable',
    prescriptions: List<String>.from(map['prescriptions'] ?? []),
  );
}
