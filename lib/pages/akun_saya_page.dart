import 'package:flutter/material.dart';

import 'login_page.dart';
import 'tiket_saya_page.dart';

// ============================================================
// DATA SATU BARIS MENU (icon, label, aksi saat ditekan)
// ============================================================
class _MenuItemData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItemData({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class AkunSayaPage extends StatefulWidget {
  final String headerImagePath;
  final String userName;
  final String userPhone;

  const AkunSayaPage({
    super.key,
    this.headerImagePath = 'assets/images/header_travel.png',
    this.userName = 'Achmad Rafi Ilmal',
    this.userPhone = '081234567896',
  });

  @override
  State<AkunSayaPage> createState() => _AkunSayaPageState();
}

class _AkunSayaPageState extends State<AkunSayaPage> {
  static const Color primaryBlue = Color(0xFF1769C2);
  static const Color titleColor = Color(0xFF172B4D);
  static const Color textColor = Color(0xFF6F82A5);
  static const Color borderColor = Color(0xFFEDF0F5);
  static const Color backgroundColor = Color(0xFFF5F7FA);

  // Placeholder aksi untuk menu yang belum ada halamannya.
  // TODO: ganti dengan navigasi ke halaman sesungguhnya masing-masing.
  void _onMenuTap(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Buka halaman "$label"')),
    );
  }

  void _onKeluarAkun() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Keluar Akun'),
          content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                // Hapus semua riwayat navigasi, kembali ke LoginPage
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
              child: const Text(
                'Keluar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              // Dibatasi maksimal 480 dan diterapkan ke SELURUH isi
              // halaman (header + kartu profil + menu), supaya semua
              // bagian punya lebar yang konsisten di layar lebar
              // (desktop) — bukan cuma bagian menu saja seperti
              // sebelumnya, yang menyebabkan header & kartu profil
              // melebar sendiri mengikuti lebar layar penuh.
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                children: [
                  _buildHeaderSection(),
                  const SizedBox(height: 55),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel('Aktivitas & Keamanan'),
                        const SizedBox(height: 8),
                        _menuCard([
                          _MenuItemData(
                            icon: Icons.lock_outline,
                            label: 'Ganti Kata Sandi',
                            onTap: () => _onMenuTap('Ganti Kata Sandi'),
                          ),
                          _MenuItemData(
                            icon: Icons.history_rounded,
                            label: 'Riwayat Perjalanan',
                            onTap: () => _onMenuTap('Riwayat Perjalanan'),
                          ),
                          _MenuItemData(
                            icon: Icons.people_outline_rounded,
                            label: 'Daftar Penumpang Favorit',
                            onTap: () =>
                                _onMenuTap('Daftar Penumpang Favorit'),
                          ),
                          _MenuItemData(
                            icon: Icons.credit_card_outlined,
                            label: 'Metode Pembayaran Saya',
                            onTap: () =>
                                _onMenuTap('Metode Pembayaran Saya'),
                          ),
                        ]),
                        const SizedBox(height: 22),

                        _sectionLabel('Informasi & Panduan Travel'),
                        const SizedBox(height: 8),
                        _menuCard([
                          _MenuItemData(
                            icon: Icons.location_on_outlined,
                            label: 'Daftar Lokasi Pool',
                            onTap: () => _onMenuTap('Daftar Lokasi Pool'),
                          ),
                          _MenuItemData(
                            icon: Icons.luggage_outlined,
                            label: 'Aturan & Kapasitas Bagasi',
                            onTap: () =>
                                _onMenuTap('Aturan & Kapasitas Bagasi'),
                          ),
                          _MenuItemData(
                            icon: Icons.support_agent_outlined,
                            label: 'Pusat Bantuan',
                            onTap: () => _onMenuTap('Pusat Bantuan'),
                          ),
                          _MenuItemData(
                            icon: Icons.info_outline_rounded,
                            label: 'Tentang Aplikasi',
                            onTap: () => _onMenuTap('Tentang Aplikasi'),
                          ),
                        ]),
                        const SizedBox(height: 22),

                        _sectionLabel('Login'),
                        const SizedBox(height: 8),
                        _menuCard([
                          _MenuItemData(
                            icon: Icons.devices_other_outlined,
                            label: 'Perangkat Tertaut',
                            onTap: () => _onMenuTap('Perangkat Tertaut'),
                          ),
                          _MenuItemData(
                            icon: Icons.person_remove_outlined,
                            label: 'Hapus Akun',
                            onTap: () => _onMenuTap('Hapus Akun'),
                          ),
                        ]),
                        const SizedBox(height: 22),

                        Center(
                          child: TextButton(
                            onPressed: _onKeluarAkun,
                            child: const Text(
                              'Keluar Akun',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // ============================================================
  // HEADER (foto + tombol back + judul + kartu profil overlap)
  // ============================================================
  Widget _buildHeaderSection() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: double.infinity,
          height: 190,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                widget.headerImagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2E4A7D), primaryBlue],
                      ),
                    ),
                  );
                },
              ),
              // Overlay gelap tipis supaya tulisan putih tetap terbaca
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.25),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: 40),
                          child: Center(
                            child: Text(
                              'Akun Saya',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: -55,
          child: _buildProfileCard(),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFE9EEF6),
                child: Icon(
                  Icons.person,
                  color: primaryBlue.withOpacity(0.7),
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.userName,
                      style: const TextStyle(
                        color: titleColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.userPhone,
                      style: const TextStyle(
                        color: textColor,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton(
              onPressed: () => _onMenuTap('Detail Akun'),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryBlue,
                side: const BorderSide(color: primaryBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Detail Akun',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // JUDUL SETIAP BAGIAN (Aktivitas & Keamanan, dst.)
  // ============================================================
  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: primaryBlue,
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
    );
  }

  // ============================================================
  // KARTU BERISI SEKUMPULAN MENU (dipisah garis tipis)
  // ============================================================
  Widget _menuCard(List<_MenuItemData> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _menuTile(items[i]),
            if (i != items.length - 1)
              const Divider(height: 1, indent: 50, color: borderColor),
          ],
        ],
      ),
    );
  }

  Widget _menuTile(_MenuItemData item) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(item.icon, size: 20, color: textColor),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.label,
                style: const TextStyle(
                  color: titleColor,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Color(0xFFB8C2D9),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION (item "Akun" aktif)
  // ============================================================
  Widget _buildBottomNavigation() {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        height: 68,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFE5E5E5), width: 0.7),
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: BottomNavigationBar(
              currentIndex: 3,
              onTap: (index) {
                if (index == 3) return; // sudah di halaman Akun

                if (index == 0) {
                  // Beranda: kembali langsung ke HomePage (halaman
                  // paling awal setelah login), tidak peduli berapa
                  // banyak halaman tab lain yang sudah ditumpuk.
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  return;
                }

                if (index == 1) {
                  // Tiket Saya: langsung ganti halaman ini dengan
                  // TiketSayaPage (pushReplacement), supaya tidak
                  // menumpuk halaman Akun di bawahnya.
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const TiketSayaPage()),
                  );
                  return;
                }

                if (index == 2) {
                  // TODO: ganti dengan navigasi ke halaman Notifikasi
                  // sesungguhnya kalau sudah dibuat.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Halaman Notifikasi belum tersedia'),
                    ),
                  );
                }
              },
              backgroundColor: Colors.white,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: primaryBlue,
              unselectedItemColor: const Color(0xFF999999),
              selectedFontSize: 9,
              unselectedFontSize: 9,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined, size: 22),
                  activeIcon: Icon(Icons.home_rounded, size: 22),
                  label: 'Beranda',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.confirmation_num_outlined, size: 22),
                  activeIcon: Icon(Icons.confirmation_num_rounded, size: 22),
                  label: 'Tiket Saya',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.mail_outline_rounded, size: 22),
                  activeIcon: Icon(Icons.mail_rounded, size: 22),
                  label: 'Notifikasi',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded, size: 22),
                  activeIcon: Icon(Icons.person_rounded, size: 22),
                  label: 'Akun',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}