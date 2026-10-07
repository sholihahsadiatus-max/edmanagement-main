import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _nama = 'Rika';
  String _telepon = '08888899991';
  String _email = 'Rika22@gmail.com';

  // Getter
  String get nama => _nama;
  String get telepon => _telepon;
  String get email => _email;

  // Fungsi untuk memperbarui data dari mana saja
  void updateProfile({
    required String nama,
    required String telepon,
    required String email,
  }) {
    _nama = nama;
    _telepon = telepon;
    _email = email;
    
    // Memberitahu seluruh halaman/widget untuk otomatis memperbarui tampilannya
    notifyListeners();
  }
}