import 'package:edmanagement/screens/edit_akun_screen.dart';
import 'package:flutter/material.dart';
import 'pesanan_saya_screen.dart';
import 'alamat_saya_screen.dart';

class AkunScreen extends StatelessWidget {
  const AkunScreen({super.key});

  final Color primaryColor = const Color(0xFF006B42);
  final Color backgroundColor = const Color(0xFFF7F0ED); // Warna background krem muda

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Atas (Hijau) dengan Kartu Profil
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Background Hijau Atas
                Container(
                  height: 180,
                  width: double.infinity,
                  color: primaryColor,
                  padding: const EdgeInsets.only(left: 24, right: 24, top: 48),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Akun',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                // Kartu Profil Melayang
                Padding(
                  padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Foto Profil, Nama, Email
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 28,
                              backgroundColor: Color(0xFFE0E0E0),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Rika',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Rikaa22@gmail.com',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Stats: Pesanan, Keranjang, Alamat
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem(
                              icon: Icons.shopping_bag_outlined,
                              count: '4',
                              label: 'Pesanan',
                            ),
                            Container(height: 24, width: 1, color: Colors.grey.shade300),
                            _buildStatItem(
                              icon: Icons.favorite_border,
                              count: '2',
                              label: 'Keranjang',
                            ),
                            Container(height: 24, width: 1, color: Colors.grey.shade300),
                            _buildStatItem(
                              icon: Icons.location_on_outlined,
                              count: '',
                              label: 'Alamat',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Section: Menu Saya
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Menu Saya',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildMenuItem('Pesanan Saya', onTap: () {
                          Navigator.push(context,
                            MaterialPageRoute(builder: (context) => const PesananSayaScreen(),
                            ),
                            );
                        },
                        ),
                        _buildDivider(),
                        _buildMenuItem('Keranjang', onTap: () {}),
                        _buildDivider(),
                        _buildMenuItem('Alamat', onTap: () {
                          Navigator.push(context,
                          MaterialPageRoute(builder: (context) => const AlamatSayaScreen(),
                          ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section: Pengaturan
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pengaturan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildMenuItem('Akun', onTap: () {
                          Navigator.push(context,
                            MaterialPageRoute(builder: (context) => const EditAkunScreen()),
                          );
                        }),
                        _buildDivider(),
                        _buildMenuItem('Tentang Aplikasi', onTap: () {}),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Tombol Keluar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // Logika Keluar/Logout
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      SizedBox(width: 12),
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 12),
                      Text(
                        'Keluar',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Helper Widget untuk Item Stat (Pesanan, Keranjang, Alamat)
  Widget _buildStatItem({
    required IconData icon,
    required String count,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, size: 22, color: primaryColor),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (count.isNotEmpty)
              Text(
                count,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper Widget untuk Baris Menu
  Widget _buildMenuItem(String title, {required VoidCallback onTap}) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.black87),
      onTap: onTap,
    );
  }

  // Helper Divider Tipis
  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade100,
      indent: 16,
      endIndent: 16,
    );
  }
}