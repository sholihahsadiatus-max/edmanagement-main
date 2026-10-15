import 'package:flutter/material.dart';
import 'laporan_penjualan_screen.dart';
import 'pengaturan_akun_screen.dart';

class TokoSayaScreen extends StatelessWidget {
  const TokoSayaScreen({super.key});

  static const Color hijau = Color(0xFF006B42);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: Color(0xFFE0F2E9),
                child: Icon(Icons.storefront, size: 40, color: hijau),
              ),
              SizedBox(height: 12),
              Text(
                'Toko UMKM Saya',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 6),
              Text(
                'Lengkapi informasi toko kamu.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _kartuMenu(
          context,
          Icons.store_outlined,
          'Informasi Toko',
          'Nama, deskripsi, dan alamat toko',
          () => _pesan(context, 'Form informasi toko akan dibuat berikutnya.'),
        ),
        _kartuMenu(
          context,
          Icons.phone_outlined,
          'Nomor WhatsApp',
          'Kontak yang dapat dihubungi pembeli',
          () => _pesan(context, 'Pengaturan WhatsApp akan dibuat berikutnya.'),
        ),
        _kartuMenu(
          context,
          Icons.bar_chart_outlined,
          'Laporan Penjualan',
          'Lihat ringkasan hasil penjualan',
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LaporanPenjualanScreen()),
          ),
        ),
        _kartuMenu(
          context,
          Icons.settings_outlined,
          'Pengaturan Akun',
          'Keamanan dan pengaturan akun',
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PengaturanAkunScreen()),
          ),
        ),
        _kartuMenu(
          context,
          Icons.logout,
          'Keluar',
          'Keluar dari akun penjual',
          () => _konfirmasiKeluar(context),
        ),
      ],
    );
  }

  Widget _kartuMenu(
    BuildContext context,
    IconData ikon,
    String judul,
    String deskripsi,
    VoidCallback aksi,
  ) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE7ECE8)),
      ),
      child: ListTile(
        onTap: aksi,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE0F2E9),
          child: Icon(ikon, color: hijau),
        ),
        title: Text(
          judul,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(deskripsi, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }

  void _pesan(BuildContext context, String isi) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isi)));
  }

  void _konfirmasiKeluar(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Keluar dari akun?'),
          content: const Text(
            'Apakah kamu yakin ingin keluar dari akun penjual?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _pesan(
                  context,
                  'Hubungkan tombol ini ke Supabase Auth untuk logout.',
                );
              },
              child: const Text('Keluar', style: TextStyle(color: hijau)),
            ),
          ],
        );
      },
    );
  }
}
