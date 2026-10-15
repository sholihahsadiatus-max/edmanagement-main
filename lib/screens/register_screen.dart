import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'pembeli/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _addressController = TextEditingController();

  // TAMBAHAN: CONTROLLER NAMA USAHA
  final TextEditingController _businessNameController = TextEditingController();

  bool _obscureText = true;
  bool _isLoading = false;

  // ROLE PEMBELI ATAU PENJUAL
  String _selectedRole = 'buyer';

  final Color primaryColor = const Color(0xFF006B42);

  Future<void> _register() async {
    final nama = _nameController.text.trim();
    final noHandphone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final alamat = _addressController.text.trim();

    // TAMBAHAN: AMBIL NAMA USAHA
    final namaUsaha = _businessNameController.text.trim();

    // =========================
    // VALIDASI
    // =========================

    if (nama.isEmpty) {
      _showMessage('Nama harus diisi');
      return;
    }

    if (noHandphone.isEmpty) {
      _showMessage('No handphone harus diisi');
      return;
    }

    if (email.isEmpty) {
      _showMessage('Email harus diisi');
      return;
    }

    if (password.isEmpty) {
      _showMessage('Password harus diisi');
      return;
    }

    if (password.length < 6) {
      _showMessage('Password minimal 6 karakter');
      return;
    }

    if (alamat.isEmpty) {
      _showMessage('Alamat harus diisi');
      return;
    }

    // TAMBAHAN: NAMA USAHA WAJIB UNTUK PENJUAL
    if (_selectedRole == 'seller' && namaUsaha.isEmpty) {
      _showMessage('Nama usaha harus diisi');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;

      // =========================
      // REGISTER SUPABASE AUTH
      // =========================

      final response = await supabase.auth.signUp(
        email: email,
        password: password,

        // DATA UNTUK TRIGGER PEMBUATAN PROFIL
        data: {
          'nama': nama,
          'no_handphone': noHandphone,
          'alamat': alamat,
          'role': _selectedRole,

          // TAMBAHAN: NAMA USAHA
          'nama_usaha': _selectedRole == 'seller' ? namaUsaha : null,
        },
      );

      if (response.user == null) {
        throw Exception('Akun gagal dibuat');
      }

      if (!mounted) return;

      // =========================
      // JIKA KONFIRMASI EMAIL AKTIF
      // =========================

      if (response.session == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _selectedRole == 'seller'
                  ? 'Pendaftaran penjual berhasil. '
                        'Silakan konfirmasi email dan tunggu '
                        'persetujuan admin.'
                  : 'Pendaftaran berhasil. Silakan cek email '
                        'untuk konfirmasi, lalu login.',
            ),
            backgroundColor: primaryColor,
          ),
        );

        Navigator.pop(context);
      }
      // =========================
      // JIKA KONFIRMASI EMAIL NONAKTIF
      // =========================
      else {
        // =========================
        // ROLE PENJUAL
        // MENUNGGU PERSETUJUAN ADMIN
        // =========================

        if (_selectedRole == 'seller') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Pendaftaran berhasil. Akun penjual '
                'menunggu persetujuan admin.',
              ),
              backgroundColor: primaryColor,
            ),
          );

          // KEMBALI KE HALAMAN LOGIN
          // PENJUAL TIDAK LANGSUNG MASUK DASHBOARD
          await supabase.auth.signOut();

          if (!mounted) return;

          Navigator.pop(context);
        }
        // =========================
        // ROLE PEMBELI
        // TETAP MASUK HOME SCREEN
        // =========================
        else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pendaftaran pembeli berhasil.'),
              backgroundColor: Color(0xFF006B42),
            ),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (Route<dynamic> route) => false,
          );
        }
      }
    }
    // =========================
    // ERROR SUPABASE AUTH
    // =========================
    on AuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pendaftaran gagal: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
    // =========================
    // ERROR LAIN
    // =========================
    catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
    // =========================
    // SELESAI LOADING
    // =========================
    finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // =========================
  // PESAN
  // =========================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // =========================
  // DISPOSE
  // =========================

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _addressController.dispose();

    // TAMBAHAN
    _businessNameController.dispose();

    super.dispose();
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // =========================
              // NAVIGASI
              // =========================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),

                  IconButton(
                    icon: const Icon(Icons.arrow_forward, color: Colors.black),
                    onPressed: () {},
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // =========================
              // LOGO
              // =========================
              Center(
                child: Image.asset(
                  'assets/logo.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.image_not_supported_outlined,
                      size: 90,
                      color: primaryColor,
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // =========================
              // JUDUL
              // =========================
              const Text(
                'Selamat Datang !',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 28),

              // =========================
              // NAMA
              // =========================
              const Text(
                'Nama',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 6),

              TextField(
                controller: _nameController,
                decoration: _inputDecoration('Masukkan nama'),
              ),

              const SizedBox(height: 16),

              // =========================
              // NO HANDPHONE
              // =========================
              const Text(
                'No handphone',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 6),

              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration('Masukkan no handphone'),
              ),

              const SizedBox(height: 16),

              // =========================
              // EMAIL
              // =========================
              const Text(
                'Email',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 6),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration('Masukkan email'),
              ),

              const SizedBox(height: 16),

              // =========================
              // PASSWORD
              // =========================
              const Text(
                'Password',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 6),

              TextField(
                controller: _passwordController,
                obscureText: _obscureText,
                decoration: _inputDecoration('Masukkan password').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // =========================
              // ALAMAT
              // =========================
              const Text(
                'Alamat Lengkap',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 6),

              TextField(
                controller: _addressController,
                maxLines: 2,
                decoration: _inputDecoration('Masukkan alamat lengkap'),
              ),

              const SizedBox(height: 16),

              // =========================
              // PILIH ROLE
              // =========================
              const Text(
                'Daftar sebagai',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 6),

              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                decoration: _inputDecoration('Pilih role').copyWith(
                  prefixIcon: Icon(Icons.person_outline, color: primaryColor),
                ),
                items: const [
                  DropdownMenuItem<String>(
                    value: 'buyer',
                    child: Text('Pembeli'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'seller',
                    child: Text('Penjual'),
                  ),
                ],
                onChanged: _isLoading
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            _selectedRole = value;
                          });
                        }
                      },
              ),

              const SizedBox(height: 16),

              // =========================
              // TAMBAHAN: NAMA USAHA
              // HANYA UNTUK PENJUAL
              // =========================
              if (_selectedRole == 'seller') ...[
                const Text(
                  'Nama Usaha',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 6),

                TextField(
                  controller: _businessNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: _inputDecoration('Masukkan nama usaha Anda')
                      .copyWith(
                        prefixIcon: Icon(
                          Icons.storefront_outlined,
                          color: primaryColor,
                        ),
                      ),
                ),

                const SizedBox(height: 16),
              ],

              // =========================
              // INFORMASI ROLE
              // =========================
              Text(
                _selectedRole == 'seller'
                    ? 'Pendaftaran penjual akan menunggu '
                          'persetujuan admin.'
                    : 'Anda akan diarahkan ke dashboard pembeli.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 32),

              // =========================
              // BUTTON DAFTAR
              // =========================
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'DAFTAR',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // INPUT DECORATION
  // =========================

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 1.5),
      ),
    );
  }
}
