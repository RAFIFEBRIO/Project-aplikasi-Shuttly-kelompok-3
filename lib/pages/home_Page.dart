import 'package:flutter/material.dart';

import 'vehicle_selection_page.dart';
import 'akun_saya_page.dart';
import 'tiket_saya_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ============================================================
  // CONSTANT
  // ============================================================

  static const Color primaryBlue = Color(0xFF1769C2);
  static const Color backgroundColor = Color(0xFFF5F7FA);

  int _currentIndex = 0;

  // ============================================================
  // DAFTAR KOTA (untuk form Keberangkatan / Tujuan)
  // ============================================================

  static const List<_CityOption> _cityOptions = [
    _CityOption(city: 'Surabaya', code: 'SBY', point: 'Pool Pusat'),
    _CityOption(city: 'Malang', code: 'MLG', point: 'Drop Point'),
    _CityOption(city: 'Sidoarjo', code: 'SDA', point: 'Pool Pusat'),
    _CityOption(city: 'Gresik', code: 'GRS', point: 'Drop Point'),
    _CityOption(city: 'Jember', code: 'JBR', point: 'Pool Pusat'),
    _CityOption(city: 'Kediri', code: 'KDR', point: 'Drop Point'),
    _CityOption(city: 'Madiun', code: 'MDN', point: 'Pool Pusat'),
    _CityOption(city: 'Banyuwangi', code: 'BWI', point: 'Drop Point'),
  ];

  // Kota yang sedang dipilih di form (default: sesuai desain awal)
  _CityOption _origin = _cityOptions[0]; // Surabaya (Pool Pusat)
  _CityOption _destination = _cityOptions[1]; // Malang (Drop Point)

  // Tanggal & jumlah penumpang yang sedang dipilih di form
  DateTime _departureDate = DateTime.now();
  int _passengerCount = 1;

  String get _departureDateLabel {
    const List<String> bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${_departureDate.day} ${bulan[_departureDate.month - 1]} ${_departureDate.year}';
  }

  // ============================================================
  // RESPONSIVE BREAKPOINT
  //
  // Semua breakpoint sekarang dihitung dari `width` yang berasal
  // dari LayoutBuilder (bukan MediaQuery), supaya ukurannya selalu
  // konsisten dengan ruang yang benar-benar tersedia untuk widget
  // ini — baik saat dijalankan full-screen maupun saat halaman ini
  // ditempel di dalam layout lain (mis. side panel di desktop).
  // ============================================================

  bool _isXs(double width) => width < 360; // HP kecil
  bool _isMobile(double width) => width < 600;
  bool _isTablet(double width) => width >= 600 && width < 1000;
  bool _isDesktop(double width) => width >= 1000;

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        top: false,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;

            // ==================================================
            // PENTING:
            //
            // Header dan konten (search card + promo) sengaja
            // digabung dalam SATU widget scroll (SingleChildScrollView
            // + Column), BUKAN CustomScrollView dengan beberapa
            // SliverToBoxAdapter terpisah.
            //
            // Alasannya: setiap sliver punya batas gambar
            // (paint extent) sendiri. Kalau search card di-
            // Transform.translate naik untuk overlap ke header,
            // dan header/card ada di sliver yang berbeda, bagian
            // yang naik itu akan TERPOTONG di batas sliver
            // (bukan malah ketiban gambar header) — inilah yang
            // menyebabkan label "KEBERANGKATAN" hilang padahal
            // gambar van tetap utuh. Dengan satu Column biasa,
            // overlap-nya aman karena semuanya berada dalam satu
            // area gambar yang sama.
            // ==================================================

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),

              child: Column(
                children: [

                  // ==============================================
                  // HEADER + SEARCH CARD
                  //
                  // Search card memang dibuat overlap ke header.
                  // Masalah sebelumnya: bagian card yang berada di luar
                  // ukuran Stack tidak ikut menerima hit-test Flutter,
                  // sehingga TGL. BERANGKAT, PENUMPANG, dan tombol CARI
                  // terlihat tetapi sulit/tidak bisa ditekan.
                  //
                  // Solusi: Stack sekarang diberi tinggi sampai ke bagian
                  // bawah search card. Jadi seluruh area visual card
                  // berada di dalam area hit-test yang sama.
                  // ==============================================

                  SizedBox(
                    height: _headerHeight(width) +
                        _searchCardHeight(width) -
                        _searchCardOverlap(width),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _buildHeader(width),
                        Positioned(
                          left: 0,
                          right: 0,
                          top: _headerHeight(width) -
                              _searchCardOverlap(width),
                          child: Center(
                            child: ConstrainedBox(
                              constraints:
                                  const BoxConstraints(maxWidth: 1200),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: _isDesktop(width)
                                      ? 24
                                      : _isTablet(width)
                                          ? 20
                                          : 12,
                                ),
                                child: _buildSearchCard(width),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ==============================================
                  // CONTENT
                  // ==============================================

                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 1200,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: _isDesktop(width)
                              ? 24
                              : _isTablet(width)
                                  ? 20
                                  : 12,
                        ),

                        child: Column(
                          children: [

                            // ========================================
                            // SPACER TAK TERLIHAT
                            //
                            // Search card sekarang berada di dalam
                            // Stack di atas (bukan lagi di sini), jadi
                            // butuh "pengganjal" tak terlihat sebesar
                            // search card supaya konten di bawahnya
                            // (promo) tidak ketiban/ketutupan tumpukan
                            // search card yang menumpuk ke header.
                            // ========================================

                            // Search card sudah masuk ke dalam tinggi
                            // Stack di atas, sehingga spacer yang dibutuhkan
                            // di sini cukup sebesar bagian overlap-nya.
                            SizedBox(
                              height: _searchCardOverlap(width),
                            ),

                            // ========================================
                            // PROMO
                            // ========================================

                            Transform.translate(
                              offset: Offset(
                                0,
                                -_promoOverlap(width),
                              ),

                              child: _buildPromoSection(
                                width,
                              ),
                            ),

                            const SizedBox(
                              height: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),

      // ==========================================================
      // BOTTOM NAVIGATION
      // ==========================================================

      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // ============================================================
  // TINGGI HEADER
  //
  // Diekstrak jadi method terpisah (dipakai baik oleh _buildHeader
  // maupun oleh build() untuk menghitung posisi search card),
  // supaya nilainya selalu konsisten di kedua tempat.
  // ============================================================
  double _headerHeight(double width) {
    if (width >= 1400) {
      return 490; // Monitor besar
    } else if (width >= 1000) {
      return 460; // Laptop / desktop
    } else if (width >= 600) {
      return 380; // Tablet
    } else if (width < 360) {
      return 280; // HP kecil
    } else {
      return 300; // HP
    }
  }

  // Seberapa jauh search card "naik" menumpuk ke atas header
  double _searchCardOverlap(double width) {
    return _isDesktop(width)
        ? 145
        : _isTablet(width)
            ? 125
            : 105;
  }

  // Tinggi aktual search card berdasarkan breakpoint yang sama dengan
  // padding, row, dan tombol di dalam _buildSearchCard().
  // Nilai ini dipakai agar seluruh area card ikut masuk hit-test Stack.
  double _searchCardHeight(double width) {
    final double padding = width >= 1000
        ? 18 * 2
        : width >= 600
            ? 16 * 2
            : _isXs(width)
                ? 9 * 2
                : 11 * 2;

    final double locationHeight = _locationRowHeight(width) * 2;

    final double sectionGap = width >= 1000 ? 12 : 10;

    final double infoHeight = width >= 1000
        ? 56
        : width >= 600
            ? 51
            : _isXs(width)
                ? 40
                : 43;

    final double buttonHeight = width >= 1000
        ? 48
        : width >= 600
            ? 45
            : _isXs(width)
                ? 38
                : 40;

    // Ada 2 gap: antara lokasi -> info dan info -> tombol.
    return padding +
        locationHeight +
        sectionGap +
        infoHeight +
        sectionGap +
        buttonHeight;
  }

  // Seberapa jauh promo "naik" mendekati search card
  double _promoOverlap(double width) {
    return _isDesktop(width)
        ? 120
        : _isTablet(width)
            ? 105
            : 85;
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(double width) {
    double headerHeight = _headerHeight(width);

    return SizedBox(
      width: double.infinity,
      height: headerHeight,

      child: Stack(
        fit: StackFit.expand,

        children: [

          // ========================================================
          // BACKGROUND IMAGE
          // ========================================================

          Image.asset(
            'assets/images/header_travel.png',

            width: double.infinity,
            height: headerHeight,

            fit: BoxFit.cover,

            alignment: width >= 1000
                ? const Alignment(
                    0.0,
                    -0.15,
                  )
                : width >= 600
                    ? const Alignment(
                        0.0,
                        -0.10,
                      )
                    : const Alignment(
                        0.0,
                        -0.20,
                      ),

            // ======================================================
            // FALLBACK
            //
            // Kalau asset belum ada / gagal dimuat, tampilkan
            // background gradient supaya layout tetap rapi
            // (bukan layar error merah) baik di HP maupun desktop.
            // ======================================================

            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2E4A7D),
                      primaryBlue,
                    ],
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.directions_car_filled_rounded,
                  color: Colors.white.withOpacity(0.25),
                  size: headerHeight * 0.5,
                ),
              );
            },
          ),

          // ========================================================
          // DARK OVERLAY
          // ========================================================

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,

                colors: [
                  Colors.black.withOpacity(0.48),
                  Colors.black.withOpacity(0.20),
                  Colors.black.withOpacity(0.03),
                ],

                stops: const [
                  0.0,
                  0.55,
                  1.0,
                ],
              ),
            ),
          ),

          // ========================================================
          // HEADER CONTENT
          // ========================================================
          //
          // CATATAN: Container notifikasi (lonceng) di pojok kanan
          // atas header SUDAH DIHAPUS sesuai permintaan. Sekarang
          // Row hanya berisi bagian "Welcome" saja, sehingga tidak
          // perlu ada child kedua (ikon lonceng) di sebelah kanan.
          // ========================================================

          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1200,
              ),

              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width >= 1000
                      ? 24
                      : width >= 600
                          ? 20
                          : 16,
                ),

                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.center,

                  children: [

                    // ==============================================
                    // WELCOME
                    // ==============================================

                    Expanded(
                      child: Align(
                        alignment: const Alignment(
                          0,
                          -0.6,
                        ),
                        child: Column(
                          mainAxisSize:
                              MainAxisSize.min,
                          crossAxisAlignment:
                              CrossAxisAlignment.center,

                          children: [

                          Text(
                            'Selamat Datang',

                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,

                            style: TextStyle(
                              color: Colors.white,

                              // ==========================================
                              // Font diperbesar & dibuat lebih elegan:
                              // fontFamily 'Georgia' (serif) memberi kesan
                              // lebih premium/travel dibanding default
                              // sans-serif, dengan letterSpacing tipis
                              // supaya tetap enak dibaca di atas foto.
                              // ==========================================

                              fontFamily: 'Georgia',

                              fontSize: width >= 1000
                                  ? 34
                                  : width >= 600
                                      ? 30
                                      : _isXs(width)
                                          ? 24
                                          : 27,

                              fontWeight:
                                  FontWeight.w500,

                              letterSpacing: 0.3,

                              shadows: const [
                                Shadow(
                                  color: Colors.black54,
                                  blurRadius: 6,
                                  offset: Offset(
                                    1,
                                    2,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(
                            height: 6,
                          ),

                          Text(
                            'Rafi Ilmal',

                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,

                            style: TextStyle(
                              color: Colors.white,

                              fontFamily: 'Georgia',

                              fontSize: width >= 1000
                                  ? 27
                                  : width >= 600
                                      ? 24
                                      : _isXs(width)
                                          ? 19
                                          : 21,

                              fontWeight:
                                  FontWeight.w700,

                              letterSpacing: 0.2,

                              shadows: const [
                                Shadow(
                                  color: Colors.black54,
                                  blurRadius: 6,
                                  offset: Offset(
                                    1,
                                    2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ],
                        ),
                      ),
                    ),

                    // ==============================================
                    // (Ikon notifikasi/lonceng dihapus dari sini)
                    // ==============================================
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH CARD
  // ============================================================

  Widget _buildSearchCard(double width) {
    return Container(
      width: double.infinity,

      padding: EdgeInsets.all(
        width >= 1000
            ? 18
            : width >= 600
                ? 16
                : _isXs(width)
                    ? 9
                    : 11,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(
          width >= 1000 ? 18 : 14,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),

            blurRadius: 22,

            spreadRadius: 1,

            offset: const Offset(
              0,
              8,
            ),
          ),
        ],
      ),

      child: Column(
        children: [

          // ========================================================
          // FROM / TO (dengan tombol swap rute di antara keduanya)
          // ========================================================

          _buildSwappableLocationFields(width),

          SizedBox(
            height: width >= 1000
                ? 12
                : 10,
          ),

          // ========================================================
          // DATE + PASSENGER
          // ========================================================

          Row(
            children: [

              Expanded(
                child: _buildInfoBox(
                  icon:
                      Icons.calendar_month_outlined,
                  label: 'TGL. BERANGKAT',
                  value: _departureDateLabel,
                  width: width,
                  onTap: _pickDepartureDate,
                ),
              ),

              SizedBox(
                width: width >= 1000
                    ? 12
                    : 8,
              ),

              Expanded(
                child: _buildInfoBox(
                  icon:
                      Icons.people_outline_rounded,
                  label: 'PENUMPANG',
                  value: '$_passengerCount Kursi / Seat',
                  width: width,
                  onTap: _pickPassengerCount,
                ),
              ),
            ],
          ),

          SizedBox(
            height: width >= 1000
                ? 12
                : 10,
          ),

          // ========================================================
          // SEARCH BUTTON
          // ========================================================

          SizedBox(
            width: double.infinity,

            height: width >= 1000
                ? 48
                : width >= 600
                    ? 45
                    : _isXs(width)
                        ? 38
                        : 40,

            child: ElevatedButton(
              onPressed: () {
                // ==================================================
                // AKSI CARI MOBIL TRAVEL
                //
                // Berpindah ke halaman pemilihan kendaraan, membawa
                // kota asal & tujuan yang sedang dipilih di search
                // card ('Surabaya (Pool Pusat)' -> 'Malang (Drop
                // Point)'). Kalau nanti KEBERANGKATAN/TUJUAN sudah
                // dinamis (bukan teks tetap), ganti nilai di bawah
                // ini dengan variabel state yang sesuai.
                // ==================================================

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VehicleSelectionPage(
                      originCity: _origin.city,
                      originCode: _origin.code,
                      destinationCity: _destination.city,
                      destinationCode: _destination.code,
                    ),
                  ),
                );
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,

                foregroundColor:
                    Colors.white,

                elevation: 0,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    width >= 1000
                        ? 10
                        : 8,
                  ),
                ),
              ),

              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [

                    Icon(
                      Icons.search_rounded,

                      size: width >= 1000
                          ? 22
                          : 18,
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    Text(
                      'Cari Mobil Travel',

                      style: TextStyle(
                        fontSize:
                            width >= 1000
                                ? 14
                                : 12,

                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FROM + SWAP + TO
  //
  // Membungkus row Keberangkatan & Tujuan dalam satu Stack supaya
  // tombol swap (ikon panah atas-bawah) bisa ditempel tepat di
  // atas garis pembatas (Divider) antara kedua field, menempel di
  // sisi kanan dekat radio button. Tap pada tombol ini akan
  // menukar nilai KEBERANGKATAN <-> TUJUAN.
  // ============================================================

  double _locationRowHeight(double width) {
    final bool desktop = width >= 1000;
    return desktop
        ? 62
        : width >= 600
            ? 57
            : _isXs(width)
                ? 44
                : 48;
  }

  Widget _buildSwappableLocationFields(double width) {
    final double rowHeight = _locationRowHeight(width);
    final double swapSize = width >= 1000
        ? 38
        : width >= 600
            ? 36
            : _isXs(width)
                ? 30
                : 32;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          children: [
            // ==================================================
            // KEBERANGKATAN (tap untuk buka popup pilih kota)
            // ==================================================
            _buildLocationRow(
              icon: Icons.location_on_outlined,
              label: 'KEBERANGKATAN',
              value: _origin.label,
              width: width,
              onTap: () => _showCityPicker(isOrigin: true),
            ),

            const Divider(
              height: 1,
              color: Color(0xFFE8E8E8),
            ),

            // ==================================================
            // TUJUAN (tap untuk buka popup pilih kota)
            // ==================================================
            _buildLocationRow(
              icon: Icons.flag_outlined,
              label: 'TUJUAN',
              value: _destination.label,
              width: width,
              onTap: () => _showCityPicker(isOrigin: false),
            ),
          ],
        ),

        // ======================================================
        // TOMBOL SWAP RUTE
        // ======================================================
        Positioned(
          right: width >= 1000
              ? 4
              : width >= 600
                  ? 2
                  : 0,
          top: rowHeight - (swapSize / 2),
          child: _buildSwapButton(swapSize),
        ),
      ],
    );
  }

  Widget _buildSwapButton(double size) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(
        side: BorderSide(color: Color(0xFFE0E6EF), width: 1),
      ),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.15),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _swapCities,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            Icons.swap_vert_rounded,
            color: primaryBlue,
            size: size * 0.6,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOCATION ROW
  // ============================================================

  Widget _buildLocationRow({
    required IconData icon,
    required String label,
    required String value,
    required double width,
    VoidCallback? onTap,
  }) {
    final bool desktop = width >= 1000;

    return Material(
      color: Colors.transparent,
      child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
      height: desktop
          ? 62
          : width >= 600
              ? 57
              : _isXs(width)
                  ? 44
                  : 48,

      child: Row(
        children: [

          // ======================================================
          // ICON
          // ======================================================

          SizedBox(
            width: desktop
                ? 40
                : width >= 600
                    ? 36
                    : _isXs(width)
                        ? 26
                        : 30,

            child: Icon(
              icon,

              color: primaryBlue,

              size: desktop
                  ? 23
                  : width >= 600
                      ? 21
                      : _isXs(width)
                          ? 17
                          : 19,
            ),
          ),

          // ======================================================
          // TEXT
          // ======================================================

          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  label,

                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    color:
                        Colors.grey.shade500,

                    fontSize: desktop
                        ? 9
                        : width >= 600
                            ? 8
                            : _isXs(width)
                                ? 6.5
                                : 7,

                    fontWeight:
                        FontWeight.w500,

                    letterSpacing: 0.4,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  value,

                  maxLines: 1,

                  overflow:
                      TextOverflow.ellipsis,

                  style: TextStyle(
                    color:
                        Colors.black87,

                    fontSize: desktop
                        ? 14
                        : width >= 600
                            ? 13
                            : _isXs(width)
                                ? 10
                                : 11,

                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // ======================================================
          // RADIO
          // ======================================================

          Icon(
            Icons.radio_button_unchecked,

            color:
                Colors.grey.shade400,

            size: desktop
                ? 21
                : width >= 600
                    ? 19
                    : _isXs(width)
                        ? 15
                        : 17,
          ),
        ],
      ),
      ),
      ),
    );
  }

  // ============================================================
  // INFO BOX
  // ============================================================

  Widget _buildInfoBox({
    required IconData icon,
    required String label,
    required String value,
    required double width,
    VoidCallback? onTap,
  }) {
    final bool desktop = width >= 1000;

    return Material(
      color: const Color(0xFFF3F5F8),
      borderRadius: BorderRadius.circular(desktop ? 10 : 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(desktop ? 10 : 8),
        child: Container(
      height: desktop
          ? 56
          : width >= 600
              ? 51
              : _isXs(width)
                  ? 40
                  : 43,

      padding: EdgeInsets.symmetric(
        horizontal: desktop
            ? 12
            : width >= 600
                ? 10
                : _isXs(width)
                    ? 6
                    : 8,

        vertical: desktop
            ? 7
            : 5,
      ),

      decoration: BoxDecoration(
        color: const Color(
          0xFFF3F5F8,
        ),

        borderRadius:
            BorderRadius.circular(
          desktop ? 10 : 8,
        ),
      ),

      child: Row(
        children: [

          Icon(
            icon,

            color: primaryBlue,

            size: desktop
                ? 19
                : width >= 600
                    ? 17
                    : _isXs(width)
                        ? 13
                        : 15,
          ),

          const SizedBox(
            width: 7,
          ),

          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  label,

                  maxLines: 1,

                  overflow:
                      TextOverflow.ellipsis,

                  style: TextStyle(
                    color:
                        Colors.grey.shade500,

                    fontSize: desktop
                        ? 8
                        : width >= 600
                            ? 7.5
                            : _isXs(width)
                                ? 6
                                : 6.5,

                    fontWeight:
                        FontWeight.w500,
                  ),
                ),

                const SizedBox(
                  height: 2,
                ),

                Text(
                  value,

                  maxLines: 1,

                  overflow:
                      TextOverflow.ellipsis,

                  style: TextStyle(
                    color:
                        Colors.black87,

                    fontSize: desktop
                        ? 12
                        : width >= 600
                            ? 11
                            : _isXs(width)
                                ? 8.5
                                : 9.5,

                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
      ),
    );
  }

  // ============================================================
  // PICK TANGGAL KEBERANGKATAN
  // ============================================================

  Future<void> _pickDepartureDate() async {
    final DateTime today = DateTime.now();
    final DateTime firstSelectable = DateTime(today.year, today.month, today.day);
    final DateTime safeInitial =
        _departureDate.isBefore(firstSelectable) ? firstSelectable : _departureDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: safeInitial,
      firstDate: firstSelectable,
      lastDate: firstSelectable.add(const Duration(days: 365)),
      helpText: 'Pilih Tanggal Berangkat',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: primaryBlue,
                ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted || picked == null) return;

    setState(() {
      _departureDate = picked;
    });
  }

  // ============================================================
  // PICK JUMLAH PENUMPANG
  // ============================================================

  Future<void> _pickPassengerCount() async {
    int tempCount = _passengerCount;

    final int? result = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 42,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Jumlah Penumpang',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF172B4D),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Kursi / Seat',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF172B4D),
                              ),
                            ),
                            Row(
                              children: [
                                _stepperButton(
                                  icon: Icons.remove_rounded,
                                  onTap: tempCount > 1
                                      ? () => setSheetState(
                                          () => tempCount--)
                                      : null,
                                ),
                                SizedBox(
                                  width: 40,
                                  child: Text(
                                    '$tempCount',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF172B4D),
                                    ),
                                  ),
                                ),
                                _stepperButton(
                                  icon: Icons.add_rounded,
                                  onTap: tempCount < 8
                                      ? () => setSheetState(
                                          () => tempCount++)
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () =>
                                Navigator.pop(context, tempCount),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Terapkan',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                            height:
                                MediaQuery.of(context).padding.bottom + 4),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (!mounted || result == null) return;

    setState(() {
      _passengerCount = result;
    });
  }

  Widget _stepperButton({required IconData icon, VoidCallback? onTap}) {
    final bool enabled = onTap != null;
    return Material(
      color: enabled ? const Color(0xFFF3F5F8) : const Color(0xFFF9FAFB),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(
            icon,
            size: 18,
            color: enabled ? primaryBlue : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PROMO SECTION
  //
  // Setiap banner promo sekarang punya judul/deskripsi singkat
  // di bawahnya (mengikuti contoh: judul hotel/tempat tampil di
  // bawah gambar promo, bukan di dalam gambar). Ganti teks pada
  // parameter `title` di bawah ini sesuai promo yang sebenarnya.
  // ============================================================

  Widget _buildPromoSection(double width) {
    // ==========================================================
    // DESKTOP
    // ==========================================================

    if (width >= 1000) {
      return Column(
        children: [

          // ------------------------------------------------------
          // PROMO UTAMA
          // ------------------------------------------------------

          _buildPromoBanner(
            'assets/images/promo_1.png',
            title: 'Diskon 20% Travel Surabaya - Malang',
            width: width,
          ),

          const SizedBox(
            height: 18,
          ),

          // ------------------------------------------------------
          // PROMO 2 + PROMO 3
          // ------------------------------------------------------

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Expanded(
                child: _buildPromoBanner(
                  'assets/images/promo_2.png',
                  title: 'Promo Tiket Travel Pulang Pergi',
                  width: width,
                ),
              ),

              const SizedBox(
                width: 18,
              ),

              Expanded(
                child: _buildPromoBanner(
                  'assets/images/promo_3.png',
                  title: 'Hemat Naik Travel Akhir Pekan',
                  width: width,
                ),
              ),
            ],
          ),
        ],
      );
    }

    // ==========================================================
    // TABLET
    // ==========================================================

    if (width >= 600) {
      return Column(
        children: [

          _buildPromoBanner(
            'assets/images/promo_1.png',
            title: 'Diskon 20% Travel Surabaya - Malang',
            width: width,
          ),

          const SizedBox(
            height: 14,
          ),

          Row(
            children: [

              Expanded(
                child: _buildPromoBanner(
                  'assets/images/promo_2.png',
                  title: 'Promo Tiket Travel Pulang Pergi',
                  width: width,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child: _buildPromoBanner(
                  'assets/images/promo_3.png',
                  title: 'Hemat Naik Travel Akhir Pekan',
                  width: width,
                ),
              ),
            ],
          ),
        ],
      );
    }

    // ==========================================================
    // MOBILE
    // ==========================================================

    return Column(
      children: [

        _buildPromoBanner(
          'assets/images/promo_1.png',
          title: 'Diskon 20% Travel Surabaya - Malang',
          width: width,
        ),

        const SizedBox(
          height: 10,
        ),

        _buildPromoBanner(
          'assets/images/promo_2.png',
          title: 'Promo Tiket Travel Pulang Pergi',
          width: width,
        ),

        const SizedBox(
          height: 10,
        ),

        _buildPromoBanner(
          'assets/images/promo_3.png',
          title: 'Hemat Naik Travel Akhir Pekan',
          width: width,
        ),
      ],
    );
  }

  // ============================================================
  // PROMO BANNER
  //
  // Sekarang menerima parameter `title` yang ditampilkan sebagai
  // deskripsi singkat di bawah gambar promo (mirip contoh: judul
  // hotel/tempat wisata di bawah banner diskon).
  // ============================================================

  Widget _buildPromoBanner(
    String imagePath, {
    required String title,
    required double width,
  }) {
    final bool desktop = width >= 1000;

    final double radius = desktop ? 14 : 11;

    // ==========================================================
    // Gambar promo + judul sekarang dibungkus dalam SATU kotak
    // (Container putih dengan border & shadow tipis), meniru
    // contoh gambar: gambar promo di bagian atas kotak, lalu
    // judul/deskripsi ditempel langsung di bawahnya di dalam
    // kotak putih yang sama — bukan lagi teks lepas di luar kotak.
    // ==========================================================

    return Container(
      width: double.infinity,

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(radius),

        border: Border.all(
          color: const Color(0xFFE6E9EE),

          width: 1,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),

            blurRadius: 14,

            spreadRadius: 0,

            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          // ======================================================
          // GAMBAR PROMO (hanya sudut atas yang dibulatkan, supaya
          // menyatu rapi dengan kotak judul di bawahnya)
          // ======================================================

          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(radius),
              topRight: Radius.circular(radius),
            ),

            // ==========================================================
            // TIDAK dipaksa ke AspectRatio tetap + BoxFit.cover lagi.
            //
            // Sebelumnya banner dipaksa masuk ke kotak rasio 2.75 dengan
            // BoxFit.cover, yang artinya Flutter akan MEMOTONG gambar
            // supaya pas — kalau rasio asli gambar promo beda, bagian
            // penting (badge diskon, foto mobil, dll) bisa ke-crop.
            //
            // Sekarang gambar hanya dibatasi lebarnya (width: double.infinity)
            // dengan fit: BoxFit.fitWidth, sehingga tingginya menyesuaikan
            // rasio asli gambar secara otomatis — gambar tampil UTUH,
            // tidak terpotong, di HP maupun desktop.
            // ==========================================================

            child: Image.asset(
              imagePath,

              width: double.infinity,

              fit: BoxFit.fitWidth,

              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                // Fallback tetap diberi rasio tetap supaya ada
                // tinggi yang jelas walau asset belum ada.
                return AspectRatio(
                  aspectRatio: 2.75,
                  child: Container(
                    color: primaryBlue,

                    alignment:
                        Alignment.center,

                    padding: const EdgeInsets.all(8),

                    child: const Text(
                      'Gambar promo tidak ditemukan',

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: Colors.white,

                        fontSize: 13,

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ======================================================
          // DESKRIPSI / JUDUL PROMO (di dalam kotak yang sama,
          // menempel tepat di bawah gambar)
          // ======================================================

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: desktop ? 16 : 12,
              vertical: desktop ? 14 : 11,
            ),

            child: Text(
              title,

              maxLines: 2,
              overflow: TextOverflow.ellipsis,

              style: TextStyle(
                color: Colors.black87,

                fontSize: desktop
                    ? 15
                    : width >= 600
                        ? 14
                        : _isXs(width)
                            ? 12
                            : 13,

                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  //
  // Diganti menjadi 4 item: Beranda, Tiket Saya, Notifikasi, Akun
  // (sebelumnya 3 item: Beranda, Ticket, Akun) mengikuti contoh
  // gambar footer yang diberikan.
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
            top: BorderSide(
              color: Color(0xFFE5E5E5),

              width: 0.7,
            ),
          ),
        ),

        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 650,
            ),

            child:
                BottomNavigationBar(
              currentIndex:
                  _currentIndex,

              onTap: (index) {
                // Tab "Tiket Saya" (index 1) membuka halaman Tiket Saya
                if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TiketSayaPage()),
                  );
                  return;
                }

                // Tab "Akun" (index 3) membuka halaman Akun Saya,
                // bukan sekadar mengganti tampilan di halaman ini.
                if (index == 3) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AkunSayaPage()),
                  );
                  return;
                }

                setState(() {
                  _currentIndex =
                      index;
                });
              },

              backgroundColor:
                  Colors.white,

              elevation: 0,

              type:
                  BottomNavigationBarType
                      .fixed,

              selectedItemColor:
                  primaryBlue,

              unselectedItemColor:
                  const Color(
                0xFF999999,
              ),

              selectedFontSize: 9,

              unselectedFontSize: 9,

              selectedLabelStyle:
                  const TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),

              unselectedLabelStyle:
                  const TextStyle(
                fontWeight:
                    FontWeight.w500,
              ),

              items: const [

                // =================================================
                // BERANDA
                // =================================================

                BottomNavigationBarItem(
                  icon: Icon(
                    Icons
                        .home_outlined,

                    size: 22,
                  ),

                  activeIcon:
                      Icon(
                    Icons
                        .home_rounded,

                    size: 22,
                  ),

                  label: 'Beranda',
                ),

                // =================================================
                // TIKET SAYA
                // =================================================

                BottomNavigationBarItem(
                  icon: Icon(
                    Icons
                        .confirmation_num_outlined,

                    size: 22,
                  ),

                  activeIcon:
                      Icon(
                    Icons
                        .confirmation_num_rounded,

                    size: 22,
                  ),

                  label: 'Tiket Saya',
                ),

                // =================================================
                // NOTIFIKASI
                // =================================================

                BottomNavigationBarItem(
                  icon: Icon(
                    Icons
                        .mail_outline_rounded,

                    size: 22,
                  ),

                  activeIcon:
                      Icon(
                    Icons
                        .mail_rounded,

                    size: 22,
                  ),

                  label: 'Notifikasi',
                ),

                // =================================================
                // AKUN
                // =================================================

                BottomNavigationBarItem(
                  icon: Icon(
                    Icons
                        .person_outline_rounded,

                    size: 22,
                  ),

                  activeIcon:
                      Icon(
                    Icons
                        .person_rounded,

                    size: 22,
                  ),

                  label: 'Akun',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SWAP RUTE (tukar Keberangkatan <-> Tujuan)
  // ============================================================

  void _swapCities() {
    setState(() {
      final _CityOption temp = _origin;
      _origin = _destination;
      _destination = temp;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Rute ditukar'),
        duration: const Duration(milliseconds: 900),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.only(bottom: 90, left: 40, right: 40),
      ),
    );
  }

  // ============================================================
  // POPUP PILIH KOTA
  //
  // Dipanggil saat field KEBERANGKATAN atau TUJUAN di-tap.
  // Menampilkan bottom sheet responsive berisi search box +
  // daftar kota yang bisa dipilih.
  // ============================================================

  Future<void> _showCityPicker({required bool isOrigin}) async {
    final _CityOption current = isOrigin ? _origin : _destination;
    final _CityOption other = isOrigin ? _destination : _origin;
    final TextEditingController searchController = TextEditingController();

    final _CityOption? picked = await showModalBottomSheet<_CityOption>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        List<_CityOption> filtered = List.of(_cityOptions);

        return StatefulBuilder(
          builder: (context, setSheetState) {
            void applyFilter(String query) {
              final String q = query.trim().toLowerCase();
              setSheetState(() {
                filtered = _cityOptions.where((option) {
                  return option.city.toLowerCase().contains(q) ||
                      option.point.toLowerCase().contains(q) ||
                      option.code.toLowerCase().contains(q);
                }).toList();
              });
            }

            return FractionallySizedBox(
              heightFactor: 0.75,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              isOrigin
                                  ? 'Pilih Kota Keberangkatan'
                                  : 'Pilih Kota Tujuan',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF172B4D),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            icon: const Icon(Icons.close_rounded, size: 20),
                            color: const Color(0xFF6F82A5),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F5F8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: searchController,
                          onChanged: applyFilter,
                          decoration: const InputDecoration(
                            hintText: 'Cari kota atau pool...',
                            hintStyle: TextStyle(
                              color: Color(0xFF9AA7BD),
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: Color(0xFF9AA7BD),
                              size: 20,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1, color: Color(0xFFEDEFF3)),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Text(
                                'Kota tidak ditemukan',
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) => const Divider(
                                height: 1,
                                color: Color(0xFFF1F2F5),
                                indent: 20,
                                endIndent: 20,
                              ),
                              itemBuilder: (context, index) {
                                final _CityOption option = filtered[index];
                                final bool isSelected = option == current;
                                final bool isDisabled = option == other;

                                return ListTile(
                                  onTap: () =>
                                      Navigator.pop(sheetContext, option),
                                  leading: Icon(
                                    Icons.location_on_outlined,
                                    color: isSelected
                                        ? primaryBlue
                                        : const Color(0xFF9AA7BD),
                                  ),
                                  title: Text(
                                    option.city,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? primaryBlue
                                          : const Color(0xFF172B4D),
                                    ),
                                  ),
                                  subtitle: Text(
                                    option.point,
                                    style: const TextStyle(
                                      color: Color(0xFF6F82A5),
                                      fontSize: 12.5,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? Icon(Icons.check_circle_rounded,
                                          color: primaryBlue, size: 20)
                                      : isDisabled
                                          ? Text(
                                              'sisi lain',
                                              style: TextStyle(
                                                color: Colors.grey.shade400,
                                                fontSize: 11.5,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            )
                                          : null,
                                );
                              },
                            ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 6),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    searchController.dispose();

    if (!mounted || picked == null || picked == current) return;

    // Kalau kota yang dipilih sama dengan sisi lainnya, tukar otomatis
    // supaya keberangkatan & tujuan tidak pernah sama.
    if (picked == other) {
      _swapCities();
      return;
    }

    setState(() {
      if (isOrigin) {
        _origin = picked;
      } else {
        _destination = picked;
      }
    });
  }
}

// ============================================================
// MODEL: OPSI KOTA
// ============================================================

class _CityOption {
  final String city;
  final String code;
  final String point;

  const _CityOption({
    required this.city,
    required this.code,
    required this.point,
  });

  String get label => '$city ($point)';

  @override
  bool operator ==(Object other) =>
      other is _CityOption && other.city == city && other.point == point;

  @override
  int get hashCode => Object.hash(city, point);
}