import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://cqzzrxeukcxkstdxfeiy.supabase.co',
    publishableKey: 'sb_publishable_forJiulthVcRmNGHfQUO1g_1DkiL3pq',
  );

  runApp(const MyApp());
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
      ),
      home: const LoginScreen(),
    );
  }
}