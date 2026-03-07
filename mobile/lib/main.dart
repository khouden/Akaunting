import 'package:flutter/material.dart';
import 'core/di/injection_container.dart' as di;
import 'features/auth/presentation/pages/auth_check_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const AkauntingMobileApp());
}

class AkauntingMobileApp extends StatelessWidget {
  const AkauntingMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Akaunting Mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF673AB7)),
        useMaterial3: true,
      ),
      home: const AuthCheckPage(),
    );
  }
}
