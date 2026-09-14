import 'package:flutter/material.dart';

import 'pilih_kursi_page.dart';

// ================================================================
// MODEL
// ================================================================

class VehicleOption {
  final String name;
  final String imagePath;
  final int pricePerPax;
  final String departureTime;
  final String arrivalTime;
  final int availableSeats;

  const VehicleOption({
    required this.name,
    required this.imagePath,
    required this.pricePerPax,
    required this.departureTime,
    required this.arrivalTime,
    required this.availableSeats,
  });
}

// ================================================================
// PAGE
// ================================================================

class VehicleSelectionPage extends StatefulWidget {
  final String originCity; // contoh: 'Malang'
  final String originCode; // contoh: 'MLG'
  final String destinationCity; // contoh: 'Surabaya'
  final String destinationCode; // contoh: 'SBY'

  const VehicleSelectionPage({
    super.key,
    this.originCity = 'Malang',
    this.originCode = 'MLG',
    this.destinationCity = 'Surabaya',
    this.destinationCode = 'SBY',
  });

  @override
  State<VehicleSelectionPage> createState() =>
      _VehicleSelectionPageState();
}

class _VehicleSelectionPageState
    extends State<VehicleSelectionPage> {
  // ============================================================
  // CONSTANT
  // ============================================================

  static const Color primaryBlue = Color(0xFF1769C2);
  static const Color backgroundColor = Color(0xFFF5F7FA);

  // ============================================================
  // DUMMY DATA
  //
  // Ganti / hubungkan ke data asli (API, database, dll) sesuai
  // kebutuhan. Struktur data disamakan dengan yang ada di gambar
  // contoh: nama kendaraan, harga per pax, jam berangkat & tiba.
  // ============================================================

  final List<VehicleOption> _vehicles = const [
    VehicleOption(
      name: 'HiAce Premio (CS)',
      imagePath: 'assets/images/hiace_premio.png',
      pricePerPax: 170000,
      departureTime: '07.00',
      arrivalTime: '09.00',
      availableSeats: 4,
    ),
    VehicleOption(
      name: 'Elf Isuzu Long',
      imagePath: 'assets/images/elf_isuzu_long.png',
      pricePerPax: 100000,
      departureTime: '12.15',
      arrivalTime: '14.15',
      availableSeats: 9,
    ),
    VehicleOption(
      name: 'Alphard Deluxe',
      imagePath: 'assets/images/alphard_deluxe.png',
      pricePerPax: 500000,
      departureTime: '07.00',
      arrivalTime: '09.00',
      availableSeats: 2,
    ),
    VehicleOption(
      name: 'Innova Reborn',
      imagePath: 'assets/images/innova_reborn.png',
      pricePerPax: 165000,
      departureTime: '13.00',
      arrivalTime: '14.30',
      availableSeats: 6,
    ),
  ];

  // ============================================================
  // SELECTED CARD
  //
  // Menyimpan index kendaraan yang sedang dipilih/di-tap, supaya
  // card-nya bisa ditandai dengan border biru seperti pada contoh
  // gambar (card "Alphard Deluxe" yang di-highlight).
  // ============================================================

  int? _selectedIndex;

  // ============================================================
  // RESPONSIVE BREAKPOINT
  // ============================================================

  bool _isXs(double width) => width < 360;
  bool _isTablet(double width) => width >= 600 && width < 1000;
  bool _isDesktop(double width) => width >= 1000;

  // ============================================================
  // AKSI SAAT KARTU KENDARAAN DITEKAN
  //
  // - Kartu tetap ditandai terpilih (border biru) seperti semula.
  // - Khusus kendaraan HiAce, otomatis membuka halaman Pilih Kursi.
  //   Data rute & jadwal dikirim ke halaman tersebut supaya kartu
  //   info di atasnya sesuai dengan kendaraan yang dipilih.
  // ============================================================

  void _onVehicleTap(int index, VehicleOption vehicle) {
    setState(() {
      _selectedIndex = index;
    });

    final bool isHiAce = vehicle.name.toLowerCase().contains('hiace');

    if (isHiAce) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PilihKursiPage(
            originCity: widget.originCity,
            destinationCity: widget.destinationCity,
            vehicleName: vehicle.name,
            pricePerPax: vehicle.pricePerPax,
            departureTime: vehicle.departureTime,
            arrivalTime: vehicle.arrivalTime,
          ),
        ),
      );
    }
  }

  // ============================================================
  // FORMAT HARGA
  // ============================================================

  String _formatPrice(int price) {
    final String raw = price.toString();
    final StringBuffer buffer = StringBuffer();

    for (int i = 0; i < raw.length; i++) {
      final int posFromRight = raw.length - i;

      buffer.write(raw[i]);

      if (posFromRight > 1 && posFromRight % 3 == 1) {
        buffer.write('.');
      }
    }

    return 'Rp ${buffer.toString()}';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;

            return Column(
              children: [

                // ==========================================
                // TOP BAR (back + rute)
                // ==========================================

                _buildTopBar(width),

                // ==========================================
                // LIST KENDARAAN
                // ==========================================

                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 700,
                      ),

                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(
                          horizontal: _isDesktop(width)
                              ? 24
                              : _isTablet(width)
                                  ? 20
                                  : 14,
                          vertical: 14,
                        ),

                        itemCount: _vehicles.length,

                        separatorBuilder:
                            (context, index) => SizedBox(
                          height: _isDesktop(width)
                              ? 16
                              : 12,
                        ),

                        itemBuilder: (context, index) {
                          return _buildVehicleCard(
                            _vehicles[index],
                            width,
                            isSelected:
                                _selectedIndex == index,
                            onTap: () =>
                                _onVehicleTap(index, _vehicles[index]),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar(double width) {
    final bool desktop = _isDesktop(width);

    return Container(
      width: double.infinity,

      padding: EdgeInsets.symmetric(
        horizontal: desktop ? 20 : 12,
        vertical: desktop ? 18 : 14,
      ),

      decoration: const BoxDecoration(
        color: Colors.white,

        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE5E5E5),
            width: 0.7,
          ),
        ),
      ),

      child: Row(
        children: [

          // ==========================================
          // BACK BUTTON
          // ==========================================

          InkWell(
            borderRadius: BorderRadius.circular(20),

            onTap: () {
              Navigator.of(context).maybePop();
            },

            child: Padding(
              padding: const EdgeInsets.all(6),

              child: Icon(
                Icons.arrow_back_rounded,
                color: Colors.black87,
                size: desktop ? 24 : 21,
              ),
            ),
          ),

          // ==========================================
          // RUTE (asal -> tujuan)
          // ==========================================

          Expanded(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,

                children: [

                  _buildCityLabel(
                    city: widget.originCity,
                    code: widget.originCode,
                    desktop: desktop,
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: desktop ? 18 : 12,
                    ),

                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.black54,
                      size: desktop ? 24 : 20,
                    ),
                  ),

                  _buildCityLabel(
                    city: widget.destinationCity,
                    code: widget.destinationCode,
                    desktop: desktop,
                  ),
                ],
              ),
            ),
          ),

          // ==========================================
          // SPACER supaya rute tetap center walau ada
          // back button di kiri (lebar disamakan)
          // ==========================================

          SizedBox(
            width: desktop ? 36 : 33,
          ),
        ],
      ),
    );
  }

  Widget _buildCityLabel({
    required String city,
    required String code,
    required bool desktop,
  }) {
    return Column(
      children: [

        Text(
          city,

          style: TextStyle(
            color: Colors.black87,

            fontSize: desktop ? 22 : 18,

            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          '($code)',

          style: TextStyle(
            color: Colors.grey.shade500,

            fontSize: desktop ? 14 : 12.5,

            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // VEHICLE CARD
  // ============================================================

  Widget _buildVehicleCard(
    VehicleOption vehicle,
    double width, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final bool desktop = _isDesktop(width);

    return GestureDetector(
      onTap: onTap,

      child: Container(
        width: double.infinity,

        padding: EdgeInsets.all(
          desktop ? 16 : 12,
        ),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(
            desktop ? 16 : 14,
          ),

          // ==================================================
          // BORDER SELEKSI
          //
          // Card yang sedang dipilih ditandai dengan border biru
          // (2px), persis seperti card "Alphard Deluxe" pada
          // contoh gambar. Card lain tetap tanpa border (transparan)
          // supaya ukurannya tidak "loncat" saat berpindah pilihan.
          // ==================================================

          border: Border.all(
            color: isSelected
                ? primaryBlue
                : Colors.transparent,
            width: 2,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

          // ======================================================
          // FOTO + NAMA + HARGA
          // ======================================================

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [

              // ==================================================
              // FOTO KENDARAAN
              //
              // Dibungkus Container dengan background abu muda +
              // ukuran tetap, supaya framing foto konsisten walau
              // rasio/latar foto asli tiap kendaraan beda-beda.
              // ==================================================

              Container(
                width: desktop ? 130 : 108,
                height: desktop ? 98 : 82,

                decoration: BoxDecoration(
                  color: const Color(0xFFF0F3F7),

                  borderRadius: BorderRadius.circular(
                    desktop ? 12 : 10,
                  ),
                ),

                clipBehavior: Clip.antiAlias,

                child: Image.asset(
                  vehicle.imagePath,

                  width: double.infinity,
                  height: double.infinity,

                  fit: BoxFit.cover,

                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return Icon(
                      Icons.directions_car_filled_rounded,
                      color: primaryBlue.withOpacity(0.4),
                      size: desktop ? 40 : 32,
                    );
                  },
                ),
              ),

              SizedBox(width: desktop ? 14 : 10),

              // ==================================================
              // NAMA + HARGA
              // ==================================================

              Expanded(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      vehicle.name,

                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        color: Colors.black87,

                        fontSize: desktop ? 16 : 14,

                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: desktop ? 6 : 4),

                    Text(
                      '${_formatPrice(vehicle.pricePerPax)}/pax',

                      style: TextStyle(
                        color: primaryBlue,

                        fontSize: desktop ? 15 : 13,

                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: desktop ? 8 : 6),

                    // ======================================
                    // KURSI TERSEDIA
                    // ======================================

                    Row(
                      mainAxisSize: MainAxisSize.min,

                      children: [

                        Icon(
                          Icons.event_seat_outlined,

                          color: Colors.grey.shade500,

                          size: desktop ? 15 : 13,
                        ),

                        SizedBox(width: desktop ? 5 : 4),

                        Text(
                          '${vehicle.availableSeats} kursi tersedia',

                          style: TextStyle(
                            color: Colors.grey.shade600,

                            fontSize: desktop ? 12.5 : 11,

                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: desktop ? 14 : 10),

          const Divider(
            height: 1,
            color: Color(0xFFEDEDED),
          ),

          SizedBox(height: desktop ? 12 : 10),

          // ======================================================
          // JAM BERANGKAT/TIBA + TOMBOL DETAIL
          // ======================================================

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [

              // ==================================================
              // GRUP JAM (berangkat — Sampai — tiba)
              //
              // Digabung dalam satu Row dengan mainAxisSize.min
              // supaya menempel rapat di kiri, tidak melebar dan
              // membuat teks "Sampai" jadi renggang di layar lebar.
              //
              // CATATAN: sesuai contoh gambar, kota yang muncul di
              // bawah jam berangkat adalah kota TUJUAN (destination),
              // dan di bawah jam tiba adalah kota ASAL (origin) —
              // urutan ini memang terbalik dari header rute, tapi
              // disamakan persis dengan gambar referensi.
              // ==================================================

              Row(
                mainAxisSize: MainAxisSize.min,

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  _buildTimeInfo(
                    time: vehicle.departureTime,
                    city: widget.destinationCity,
                    desktop: desktop,
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: desktop ? 10 : 7,
                    ),

                    child: Padding(
                      padding: EdgeInsets.only(
                        top: desktop ? 2 : 1,
                      ),

                      child: Text(
                        '—  Sampai  —',

                        style: TextStyle(
                          color: Colors.grey.shade500,

                          fontSize: desktop ? 11 : 9.5,

                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  _buildTimeInfo(
                    time: vehicle.arrivalTime,
                    city: widget.originCity,
                    desktop: desktop,
                  ),
                ],
              ),

              // ==================================================
              // Spacer mendorong tombol Detail ke ujung kanan,
              // berapa pun lebar card-nya.
              // ==================================================

              const Spacer(),

              // ==================================================
              // TOMBOL DETAIL
              // ==================================================

              ElevatedButton(
                onPressed: () {
                  // ==========================================
                  // AKSI LIHAT DETAIL KENDARAAN
                  // ==========================================

                  // Contoh:
                  //
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) => VehicleDetailPage(
                  //       vehicle: vehicle,
                  //     ),
                  //   ),
                  // );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,

                  elevation: 0,

                  padding: EdgeInsets.symmetric(
                    horizontal: desktop ? 22 : 16,
                    vertical: desktop ? 12 : 9,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      desktop ? 10 : 8,
                    ),
                  ),
                ),

                child: Text(
                  'Detail',

                  style: TextStyle(
                    fontSize: desktop ? 13 : 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo({
    required String time,
    required String city,
    required bool desktop,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(
          time,

          style: TextStyle(
            color: Colors.black87,

            fontSize: desktop ? 14 : 12.5,

            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          city,

          maxLines: 1,
          overflow: TextOverflow.ellipsis,

          style: TextStyle(
            color: Colors.grey.shade500,

            fontSize: desktop ? 11 : 9.5,

            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}