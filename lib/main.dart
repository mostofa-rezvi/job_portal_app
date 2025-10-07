import 'package:flutter/material.dart';
import 'package:project/pages/auth/login_page.dart';
import 'package:project/pages/home/job_list_page.dart';
import 'package:project/services/shared_preference_service.dart';

// Conditional import for database initialization
// This ensures that 'dart:io' (and sqflite_common_ffi) is only included
// when building for non-web platforms.
import 'package:project/database/database_initializer.dart'
if (dart.library.html) 'package:project/database/database_initializer_stub.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Call the platform-specific initialization function
  initializeDatabaseFactory(); // This function will be defined by the correct import

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SharedPreferenceService _prefsService = SharedPreferenceService();
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    _isLoggedIn = await _prefsService.isLoggedIn();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Job Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          elevation: 4,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: _isLoggedIn ? const JobListPage() : const JobListPage(),
    );
  }
}