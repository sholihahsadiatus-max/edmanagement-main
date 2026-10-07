import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/login_screen.dart';
import 'providers/user_provider.dart';

Future<void> main() async {
  // Memastikan Flutter sudah siap sebelum menjalankan kode async
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: 'https://cqzzrxeukcxkstdxfeiy.supabase.co',
    publishableKey: 'sb_publishable_forJiulthVcRmNGHfQUO1g_1DkiL3pq',

  );

  // Jalankan aplikasi setelah Supabase berhasil diinisialisasi
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ED Management',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        fontFamily: 'sans-serif',
        primaryColor: const Color(0xFF006B42),
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006B42),
        ),
      ),

      home: const LoginScreen(),
    );
  }
}
