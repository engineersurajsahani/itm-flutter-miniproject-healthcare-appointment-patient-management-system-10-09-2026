import 'package:flutter/widgets.dart';

import 'app.dart';
import 'data/healthcare_repository.dart';

export 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HealthcareRepository.initialize();
  runApp(const HealthcareApp());
}
