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
