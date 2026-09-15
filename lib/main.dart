import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Ganti dengan URL dan Anon Key proyek Supabase Anda sendiri
  await Supabase.initialize(
    url: 'https://cqzzrxeukcxkstdxfeiy.supabase.co/rest/v1/',
    anonKey: 'sb_publishable_forJiulthVcRmNGHfQUO1g_1DkiL3pq',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Supabase Auth',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const LoginPage(),
    );
  }
}