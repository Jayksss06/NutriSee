import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Tambahkan import ini
import 'providers/app_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_data_screen.dart';
import 'utils/app_theme.dart';

void main() {
  // 1. Wajib ditambahkan agar binding platform Flutter siap sebelum fungsi async berjalan
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Deteksi jika aplikasi berjalan di Desktop (Windows/Linux)
  if (Platform.isWindows || Platform.isLinux) {
    // Inisialisasi FFI untuk SQLite
    sqfliteFfiInit();
    // Ubah databaseFactory default menjadi FFI
    databaseFactory = databaseFactoryFfi;
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const NutriseeApp(),
    ),
  );
}

class NutriseeApp extends StatelessWidget {
  const NutriseeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nutrisee',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/otp': (_) => const OtpScreen(),
        '/profile-setup': (_) => const ProfileSetupScreen(),
        '/home': (_) => const HomeScreen(),
        '/add-data': (_) => const AddDataScreen(),
      },
    );
  }
}