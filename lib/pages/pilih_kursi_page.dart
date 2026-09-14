import 'package:flutter/material.dart';

import 'pembayaran_page.dart';

/// Status kursi
enum SeatStatus { tersedia, dipilih, terisi, kosong }

class SeatData {
  final String label;
  final SeatStatus status;
  const SeatData(this.label, this.status);
}

class PilihKursiPage extends StatefulWidget {
  // ============================================================
  // DATA DARI HALAMAN VEHICLE SELECTION
  //
  // Semua parameter diberi nilai default supaya halaman ini tetap
  // bisa dibuka langsung (mis. saat development/testing) tanpa
  // harus selalu mengirim data dari halaman sebelumnya.
  // ============================================================

  final String originCity;
  final String destinationCity;
  final String vehicleName;
  final String vehicleImagePath;
  final int pricePerPax;
  final String departureTime;
  final String arrivalTime;
  final String dateLabel;

  const PilihKursiPage({
    super.key,
    this.originCity = 'Surabaya',
    this.destinationCity = 'Malang',
    this.vehicleName = 'HIACE',
    this.vehicleImagePath = 'assets/images/hiace_premio.png',
    this.pricePerPax = 170000,
    this.departureTime = '17:30',
    this.arrivalTime = '02:00',
    this.dateLabel = 'Fri, 11 Sep 2026',
  });

  @override
  State<PilihKursiPage> createState() => _PilihKursiPageState();
}

class _PilihKursiPageState extends State<PilihKursiPage> {
  // Data kursi sesuai layout pada gambar
  // Status awal: kursi 2 & 7 = terisi, sisanya tersedia (bisa dipilih user)
  final Map<String, SeatStatus> _seatStatus = {
    '1': SeatStatus.tersedia,
    '4': SeatStatus.tersedia,
    '3': SeatStatus.tersedia,
    '2': SeatStatus.terisi,
    '7': SeatStatus.terisi,
    '6': SeatStatus.tersedia,
    '5': SeatStatus.tersedia,
    '10': SeatStatus.tersedia,
    '9': SeatStatus.tersedia,
    '8': SeatStatus.tersedia,
  };

  // Menyimpan label kursi yang sedang di-hover kursor (untuk animasi
  // warna merah saat kursor mendekat ke kursi yang masih tersedia).
  String? _hoveredSeat;

  static const Color pinkColor = Color(0xFFE38B8B);
  static const Color greyColor = Color(0xFF9E9E9E);
  static const Color driverBoxColor = Color(0xFFF5F5F5);
  static const Color bgColor = Color(0xFFF7F7F7);
  static const Color primaryBlue = Color(0xFF2F6BFF);

  void _onSeatTap(String seatLabel) {
    final status = _seatStatus[seatLabel];
    if (status == SeatStatus.terisi) return; // kursi terisi tidak bisa dipilih

    setState(() {
      if (status == SeatStatus.dipilih) {
        _seatStatus[seatLabel] = SeatStatus.tersedia;
      } else {
        _seatStatus[seatLabel] = SeatStatus.dipilih;
      }
    });
  }

  Color _seatColor(SeatStatus status) {
    switch (status) {
      case SeatStatus.dipilih:
        return pinkColor;
      case SeatStatus.terisi:
        return greyColor;
      case SeatStatus.tersedia:
        return Colors.white;
      case SeatStatus.kosong:
        return Colors.transparent;
    }
  }

  // Format harga menjadi "Rp 170.000" (pemisah ribuan pakai titik)
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

  Color _seatTextColor(SeatStatus status) {
    switch (status) {
      case SeatStatus.dipilih:
      case SeatStatus.terisi:
        return Colors.white;
      default:
        return Colors.black87;
    }
  }

  // ============================================================
  // WARNA KOTAK & TEKS SAAT HOVER
  //
  // Hanya kursi berstatus "tersedia" yang bereaksi terhadap hover.
  // Saat kursor mendekat, warna kotak berubah menjadi merah (sama
  // seperti warna "dipilih") dan teksnya jadi putih agar tetap
  // terbaca — transisinya dianimasikan lewat AnimatedContainer.
  // ============================================================
  bool _isHovering(String label, SeatStatus status) {
    return status == SeatStatus.tersedia && _hoveredSeat == label;
  }

  Color _boxColorFor(String label) {
    final status = _seatStatus[label] ?? SeatStatus.tersedia;
    if (_isHovering(label, status)) return pinkColor;
    return _seatColor(status);
  }

  Color _textColorFor(String label) {
    final status = _seatStatus[label] ?? SeatStatus.tersedia;
    if (_isHovering(label, status)) return Colors.white;
    return _seatTextColor(status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Pilih Kursi',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            // ============================================================
            // BATAS LEBAR KONTEN
            //
            // Di HP, lebar layar biasanya < 420, jadi ConstrainedBox ini
            // tidak berpengaruh (tampilan tetap full-width seperti biasa).
            // Di tablet/desktop, lebar layar dibatasi maksimal 420 dan
            // otomatis berada di tengah, sehingga denah kursi tidak
            // "meregang" mengikuti lebar layar yang sangat lebar.
            // ============================================================
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTripInfoCard(),
                  const SizedBox(height: 20),
                  _buildLegend(),
                  const SizedBox(height: 20),
                  _buildSeatMap(),
                  const SizedBox(height: 20),
                  _buildLanjutkanButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Kartu info trip (Surabaya -> Malang, harga, armada, jadwal)
  Widget _buildTripInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.originCity} → ${widget.destinationCity}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                '${_formatPrice(widget.pricePerPax)}/pax',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${widget.vehicleName}| ${widget.dateLabel} '
            '${widget.departureTime} - ${widget.arrivalTime}',
            style: const TextStyle(color: Colors.grey, fontSize: 12.5),
          ),
        ],
      ),
    );
  }

  // Baris legenda: Tersedia, Dipilih, Terisi
  Widget _buildLegend() {
    Widget legendItem(Color color, String label, {bool outline = false}) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: outline ? Border.all(color: Colors.grey.shade400) : null,
            ),
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        legendItem(Colors.white, 'Tersedia', outline: true),
        legendItem(pinkColor, 'Dipilih'),
        legendItem(greyColor, 'Terisi'),
      ],
    );
  }

  // ============================================================
  // Denah kursi lengkap
  //
  // Denah dibentuk dari 3 KOLOM yang konsisten di setiap baris:
  // Kolom 1: 1, 4, 7, 10
  // Kolom 2: (kosong), 3, 6, 9
  // Kolom 3: DRIVER, 2, 5, 8
  //
  // Setiap kolom memakai Expanded + Center, sehingga lebarnya
  // selalu sama rata dan seatnya selalu sejajar vertikal, baik di
  // layar HP yang sempit maupun layar desktop yang lebar.
  // ============================================================
  Widget _buildSeatMap() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _pintuLabel(),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              children: [
                _seatRow(_seatBox('1'), _emptyBox(), _driverBox()),
                const SizedBox(height: 14),
                _seatRow(_seatBox('4'), _seatBox('3'), _seatBox('2')),
                const SizedBox(height: 14),
                _seatRow(_seatBox('7'), _seatBox('6'), _seatBox('5')),
                const SizedBox(height: 14),
                _seatRow(_seatBox('10'), _seatBox('9'), _seatBox('8')),
                const SizedBox(height: 20),
                _bagasiBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Satu baris grid berisi 3 kolom dengan lebar sama rata,
  // masing-masing kontennya diletakkan di tengah kolomnya.
  Widget _seatRow(Widget col1, Widget col2, Widget col3) {
    return Row(
      children: [
        Expanded(child: Center(child: col1)),
        Expanded(child: Center(child: col2)),
        Expanded(child: Center(child: col3)),
      ],
    );
  }

  Widget _pintuLabel() {
    return RotatedBox(
      quarterTurns: 3,
      child: Text(
        'PINTU',
        style: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w600,
          fontSize: 12,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _seatBox(String label) {
    final status = _seatStatus[label] ?? SeatStatus.tersedia;
    final bool isTersedia = status == SeatStatus.tersedia;
    final bool hovering = _isHovering(label, status);

    return MouseRegion(
      cursor: status == SeatStatus.terisi
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      onEnter: (_) {
        if (isTersedia) setState(() => _hoveredSeat = label);
      },
      onExit: (_) {
        if (isTersedia) setState(() => _hoveredSeat = null);
      },
      child: GestureDetector(
        onTap: () => _onSeatTap(label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _boxColorFor(label),
            borderRadius: BorderRadius.circular(8),
            border: (status == SeatStatus.tersedia && !hovering)
                ? Border.all(color: Colors.grey.shade300)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: _textColorFor(label),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyBox() {
    return const SizedBox(width: 56, height: 56);
  }

  Widget _driverBox() {
    return Container(
      width: 90,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: driverBoxColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Text(
        'DRIVER',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Mengambil daftar label kursi yang statusnya "dipilih"
  List<String> _selectedSeats() {
    return _seatStatus.entries
        .where((entry) => entry.value == SeatStatus.dipilih)
        .map((entry) => entry.key)
        .toList()
      ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
  }

  // ============================================================
  // TOMBOL LANJUTKAN
  //
  // Ditempatkan di bawah kotak Bagasi. Sebelum lanjut, dicek dulu
  // apakah user sudah memilih minimal 1 kursi.
  // ============================================================
  Widget _buildLanjutkanButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          final selected = _selectedSeats();

          if (selected.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pilih minimal 1 kursi terlebih dahulu'),
              ),
            );
            return;
          }

          // ============================================================
          // Pakai Navigator.push (bukan pushReplacement) supaya halaman
          // Pilih Kursi ini TETAP ada di tumpukan navigasi. Efeknya: saat
          // tombol "kembali" di halaman Pembayaran ditekan, aplikasi akan
          // kembali ke halaman Pilih Kursi ini (bukan langsung lompat ke
          // halaman lain).
          // ============================================================
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PembayaranPage(
                vehicleImagePath: widget.vehicleImagePath,
                vehicleName: widget.vehicleName,
                seatNumber: selected.join(', '),
                departureTime: widget.departureTime,
                arrivalTime: widget.arrivalTime,
                originCity: widget.originCity,
                destinationCity: widget.destinationCity,
                totalPayment: widget.pricePerPax * selected.length,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'Lanjutkan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _bagasiBox() {
    return Container(
      width: double.infinity,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'BAGASI',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Colors.black87,
        ),
      ),
    );
  }
}