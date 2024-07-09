import 'package:flutter/material.dart';
import 'package:lesson_52/services/location_service.dart';
import 'package:lesson_52/views/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Map<Permission, PermissionStatus> statuses = await [
  //   Permission.location,
  //   Permission.camera,
  // ].request();

  await LocationService.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
