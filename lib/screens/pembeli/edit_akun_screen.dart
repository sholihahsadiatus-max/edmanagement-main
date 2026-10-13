import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditAkunScreen extends StatefulWidget {
  const EditAkunScreen({super.key});

  @override
  State<EditAkunScreen> createState() => _EditAkunScreenState();
}

class _EditAkunScreenState extends State<EditAkunScreen> {
  final Color primaryColor = const Color(0xFF006B42);
  final Color backgroundColor = const Color(0xFFF7F0ED);

  final TextEditingController _namaController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _phoneController =
      TextEditingController();

  final TextEditingController _alamatController =
      TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // =========================================================
  // AMBIL DATA PROFILE
  // =========================================================
  Future<void> _loadProfile() async {
    try {
      final supabase = Supabase.instance.client;

      final user = supabase.auth.currentUser;

      debugPrint('==============================');
      debugPrint('EDIT AKUN - USER LOGIN');
      debugPrint('USER ID: ${user?.id}');
      debugPrint('USER EMAIL: ${user?.email}');
      debugPrint('==============================');

      if (user == null) {
        debugPrint('USER TIDAK LOGIN');

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }

        return;
      }

      final data = await supabase
          .from('profiles')
          .select(
            'id, nama, no_handphone, email, alamat',
          )
          .eq('id', user.id)
          .maybeSingle();

      debugPrint('DATA PROFILE: $data');

      if (data != null) {
        _namaController.text =
            data['nama']?.toString() ?? '';

        _emailController.text =
            data['email']?.toString() ??
            user.email ??
            '';

        _phoneController.text =
            data['no_handphone']?.toString() ?? '';

        _alamatController.text =
            data['alamat']?.toString() ?? '';
      } else {
        debugPrint(
          'PROFILE TIDAK DITEMUKAN UNTUK USER ID INI',
        );

        _emailController.text =
            user.email ?? '';
      }
    } catch (e) {
      debugPrint(
        'ERROR LOAD PROFILE: $e',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal mengambil data akun: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // =========================================================
  // SIMPAN PROFILE
  // =========================================================
  Future<void> _saveProfile() async {
    if (_namaController.text.trim().isEmpty) {
      _showMessage('Nama tidak boleh kosong');
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      _showMessage('Nomor HP tidak boleh kosong');
      return;
    }

    if (_alamatController.text.trim().isEmpty) {
      _showMessage('Alamat tidak boleh kosong');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final supabase = Supabase.instance.client;

      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception(
          'User belum login.',
        );
      }

      final userId = user.id;

      debugPrint('==============================');
      debugPrint('MULAI UPDATE PROFILE');
      debugPrint('USER ID: $userId');
      debugPrint(
        'NAMA BARU: ${_namaController.text.trim()}',
      );
      debugPrint(
        'NO HP BARU: ${_phoneController.text.trim()}',
      );
      debugPrint(
        'ALAMAT BARU: ${_alamatController.text.trim()}',
      );
      debugPrint('==============================');

      final result = await supabase
          .from('profiles')
          .update({
            'nama': _namaController.text.trim(),
            'no_handphone':
                _phoneController.text.trim(),
            'alamat':
                _alamatController.text.trim(),
          })
          .eq('id', userId)
          .select()
          .single();

      debugPrint('==============================');
      debugPrint('UPDATE BERHASIL');
      debugPrint('HASIL DATABASE: $result');
      debugPrint('==============================');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Data akun berhasil diperbarui',
          ),
          backgroundColor: Color(0xFF006B42),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint('==============================');
      debugPrint('UPDATE GAGAL');
      debugPrint('ERROR: $e');
      debugPrint('==============================');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menyimpan: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _alamatController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Edit Akun',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF006B42),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor:
                          const Color(0xFFE0E0E0),
                      child: const Icon(
                        Icons.person,
                        size: 52,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  _buildLabel('Nama'),

                  const SizedBox(height: 8),

                  _buildTextField(
                    controller: _namaController,
                    hintText: 'Masukkan nama',
                    icon: Icons.person_outline,
                  ),

                  const SizedBox(height: 20),

                  _buildLabel('Email'),

                  const SizedBox(height: 8),

                  TextField(
                    controller: _emailController,
                    readOnly: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                      ),
                      filled: true,
                      fillColor:
                          Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildLabel('Nomor HP'),

                  const SizedBox(height: 8),

                  _buildTextField(
                    controller: _phoneController,
                    hintText: 'Masukkan nomor HP',
                    icon: Icons.phone_outlined,
                    keyboardType:
                        TextInputType.phone,
                  ),

                  const SizedBox(height: 20),

                  _buildLabel('Alamat'),

                  const SizedBox(height: 8),

                  TextField(
                    controller: _alamatController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText:
                          'Masukkan alamat',
                      prefixIcon: const Icon(
                        Icons.location_on_outlined,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color:
                              Colors.grey.shade300,
                        ),
                      ),
                      enabledBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color:
                              Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: primaryColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving
                          ? null
                          : _saveProfile,
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            primaryColor,
                        disabledBackgroundColor:
                            Colors.grey.shade400,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color:
                                    Colors.white,
                              ),
                            )
                          : const Text(
                              'Simpan Perubahan',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight:
                                    FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
          borderSide: BorderSide(
           color: primaryColor,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}