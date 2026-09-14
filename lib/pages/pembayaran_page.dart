import 'package:flutter/material.dart';

import 'payment_success_page.dart';

class PembayaranPage extends StatefulWidget {
  // ============================================================
  // DATA PESANAN
  //
  // Dikirim dari halaman Pilih Kursi (armada, kursi yang dipilih,
  // rute, jadwal, dan total pembayaran). Semua diberi nilai default
  // supaya halaman ini tetap bisa dibuka langsung untuk keperluan
  // development/testing.
  // ============================================================

  final String vehicleImagePath;
  final String vehicleName;
  final String seatNumber;
  final String departureTime;
  final String arrivalTime;
  final String originCity;
  final String destinationCity;
  final int totalPayment;

  const PembayaranPage({
    super.key,
    this.vehicleImagePath = 'assets/images/hiace_premio.png',
    this.vehicleName = 'HiAce Premio (CS)',
    this.seatNumber = '3',
    this.departureTime = '12.15',
    this.arrivalTime = '14.15',
    this.originCity = 'Surabaya',
    this.destinationCity = 'Malang',
    this.totalPayment = 170000,
  });

  @override
  State<PembayaranPage> createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage> {
  static const Color primaryBlue = Color(0xFF2F6BFF);
  static const Color titleColor = Color(0xFF172B4D);
  static const Color textColor = Color(0xFF6F82A5);
  static const Color borderColor = Color(0xFFE9EEF6);

  // Metode pembayaran yang sedang dipilih (default: belum ada)
  String? _selectedMethod;

  // ============================================================
  // DATA PEMESAN & DATA PENUMPANG
  // ============================================================
  String _pemesanNama = '';
  String _pemesanHp = '';

  String _penumpangNama = '';
  bool _samaDenganPemesan = false;

  bool get _isPemesanFilled => _pemesanNama.trim().isNotEmpty;
  bool get _isPenumpangFilled =>
      _samaDenganPemesan || _penumpangNama.trim().isNotEmpty;

  // ============================================================
  // FORM SEDERHANA UNTUK "ISI DATA" (bottom sheet)
  // ============================================================
  Future<void> _showIsiDataSheet({
    required String title,
    required String initialNama,
    String? initialHp,
    required bool withHp,
    required void Function(String nama, String hp) onSaved,
  }) async {
    final namaController = TextEditingController(text: initialNama);
    final hpController = TextEditingController(text: initialHp ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 22,
            bottom: MediaQuery.of(context).viewInsets.bottom + 22,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: titleColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: namaController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (withHp) ...[
                const SizedBox(height: 14),
                TextField(
                  controller: hpController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'No. HP',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    onSaved(namaController.text, hpController.text);
                    Navigator.pop(context);
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
                    'Simpan',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // FORMAT HARGA -> "Rp170.000"
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

    return 'Rp${buffer.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: primaryBlue, width: 1.4),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: const Text(
              'Pembayaran',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              // Dibatasi maksimal 420 supaya rapi juga di layar lebar/desktop
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildVehicleImage(),
                    const SizedBox(height: 18),

                    // ---------------- DATA PEMESAN ----------------
                    _sectionTitle('Data Pemesan'),
                    const SizedBox(height: 8),
                    _buildIsiDataRow(
                      label: 'Isi Data Pemesan*',
                      filled: _isPemesanFilled,
                      filledLabel: _pemesanNama,
                      onTap: () => _showIsiDataSheet(
                        title: 'Data Pemesan',
                        initialNama: _pemesanNama,
                        initialHp: _pemesanHp,
                        withHp: true,
                        onSaved: (nama, hp) {
                          setState(() {
                            _pemesanNama = nama;
                            _pemesanHp = hp;
                            if (_samaDenganPemesan) {
                              _penumpangNama = nama;
                            }
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ---------------- DATA PENUMPANG ----------------
                    _sectionTitle('Data Penumpang'),
                    const SizedBox(height: 8),
                    _buildIsiDataRow(
                      label: 'Dewasa 1*',
                      filled: _isPenumpangFilled,
                      filledLabel: _penumpangNama,
                      onTap: _samaDenganPemesan
                          ? null
                          : () => _showIsiDataSheet(
                              title: 'Data Penumpang - Dewasa 1',
                              initialNama: _penumpangNama,
                              withHp: false,
                              onSaved: (nama, _) {
                                setState(() => _penumpangNama = nama);
                              },
                            ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: Checkbox(
                            value: _samaDenganPemesan,
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            activeColor: primaryBlue,
                            side: const BorderSide(color: Color(0xFFB9C7DB)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _samaDenganPemesan = value ?? false;
                                if (_samaDenganPemesan) {
                                  _penumpangNama = _pemesanNama;
                                }
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Sama dengan Data Pemesan',
                          style: TextStyle(color: textColor, fontSize: 12.5),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ---------------- RINCIAN PESANAN ----------------
                    _sectionTitle('Rincian Pesanan'),
                    const SizedBox(height: 10),
                    _buildOrderInfoCard(),

                    const SizedBox(height: 22),
                    _sectionTitle('Pilih Metode Pembayaran'),
                    const SizedBox(height: 10),
                    _buildPaymentMethodsCard(),

                    const SizedBox(height: 26),
                    _buildBayarButton(),
                    const SizedBox(height: 12),
                    _buildBatalButton(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // JUDUL SETIAP SEKSI (Data Pemesan / Data Penumpang / dst)
  // ============================================================
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: titleColor,
        fontWeight: FontWeight.w700,
        fontSize: 14.5,
      ),
    );
  }

  // ============================================================
  // BARIS "ISI DATA" (Data Pemesan / Data Penumpang)
  // Dibungkus kotak putih dengan border + shadow tipis, sesuai desain.
  // ============================================================
  Widget _buildIsiDataRow({
    required String label,
    required bool filled,
    required String filledLabel,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: filled
                    ? Text(
                        filledLabel,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: titleColor,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : RichText(
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: const TextStyle(
                            color: titleColor,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(text: label.replaceAll('*', '')),
                            const TextSpan(
                              text: '*',
                              style: TextStyle(
                                color: Color(0xFFE23744),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(width: 10),
              Text(
                filled ? 'UBAH DATA' : 'ISI DATA',
                style: const TextStyle(
                  color: primaryBlue,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FOTO KENDARAAN
  // ============================================================
  Widget _buildVehicleImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: 190,
        color: const Color(0xFFF0F3F7),
        child: Image.asset(
          widget.vehicleImagePath,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.directions_car_filled_rounded,
              color: primaryBlue.withOpacity(0.4),
              size: 60,
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // KARTU INFORMASI PESANAN (Rincian Pesanan)
  // ============================================================
  Widget _buildOrderInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Armada + nomor kursi
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Armada: ${widget.vehicleName}',
                  style: const TextStyle(
                    color: titleColor,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Seat No: ${widget.seatNumber}',
                  style: const TextStyle(
                    color: titleColor,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: borderColor),

          // Jadwal keberangkatan & tujuan
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildScheduleColumn(
                    label: 'Keberangkatan :',
                    time: widget.departureTime,
                    city: widget.originCity,
                    alignEnd: false,
                  ),
                ),
                _buildDashedArrow(),
                Expanded(
                  child: _buildScheduleColumn(
                    label: 'Tujuan:',
                    time: widget.arrivalTime,
                    city: widget.destinationCity,
                    alignEnd: true,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: borderColor),

          // Total pembayaran
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Pembayaran',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _formatPrice(widget.totalPayment),
                  style: const TextStyle(
                    color: titleColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleColumn({
    required String label,
    required String time,
    required String city,
    required bool alignEnd,
  }) {
    final crossAlign =
        alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final textAlign = alignEnd ? TextAlign.right : TextAlign.left;

    return Column(
      crossAxisAlignment: crossAlign,
      children: [
        Text(
          label,
          textAlign: textAlign,
          style: const TextStyle(color: textColor, fontSize: 12),
        ),
        const SizedBox(height: 6),
        Text(
          time,
          textAlign: textAlign,
          style: const TextStyle(
            color: titleColor,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          city,
          textAlign: textAlign,
          style: const TextStyle(color: textColor, fontSize: 12),
        ),
      ],
    );
  }

  // Panah putus-putus penghubung jam keberangkatan & kedatangan
  Widget _buildDashedArrow() {
    return Padding(
      padding: const EdgeInsets.only(top: 26),
      child: SizedBox(
        width: 70,
        height: 16,
        child: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: primaryBlue,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 2,
                child: CustomPaint(painter: _DashedLinePainter()),
              ),
            ),
            const Icon(Icons.arrow_forward, size: 16, color: primaryBlue),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BADGE IKON METODE PEMBAYARAN
  // ============================================================
  Widget _iconBadge({required IconData icon, required Color color}) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 17),
    );
  }

  // ============================================================
  // KARTU BERISI SEMUA METODE PEMBAYARAN (QRIS / OVO / Transfer Bank)
  // Digabung dalam satu kartu dengan pemisah antar baris, sesuai desain.
  // ============================================================
  Widget _buildPaymentMethodsCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          _buildPaymentMethodTile(
            id: 'qris',
            label: 'QRIS',
            leading: _iconBadge(
              icon: Icons.qr_code_2,
              color: const Color(0xFFE23744),
            ),
          ),
          const Divider(height: 1, color: borderColor),
          _buildPaymentMethodTile(
            id: 'ovo',
            label: 'OVO',
            leading: _iconBadge(
              icon: Icons.account_balance_wallet,
              color: const Color(0xFF4C2A86),
            ),
          ),
          const Divider(height: 1, color: borderColor),
          _buildPaymentMethodTile(
            id: 'bank',
            label: 'Transfer Bank',
            leading: _iconBadge(
              icon: Icons.account_balance,
              color: const Color(0xFF0060AF),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BARIS METODE PEMBAYARAN (satu baris di dalam kartu)
  // ============================================================
  Widget _buildPaymentMethodTile({
    required String id,
    required String label,
    required Widget leading,
  }) {
    final bool isSelected = _selectedMethod == id;

    return InkWell(
      onTap: () => setState(() => _selectedMethod = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        color: isSelected ? primaryBlue.withOpacity(0.05) : Colors.white,
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: titleColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Radio<String>(
              value: id,
              groupValue: _selectedMethod,
              activeColor: primaryBlue,
              onChanged: (value) => setState(() => _selectedMethod = value),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TOMBOL BAYAR
  // ============================================================
  Widget _buildBayarButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () {
          if (!_isPemesanFilled) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Isi Data Pemesan terlebih dahulu')),
            );
            return;
          }
          if (!_isPenumpangFilled) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Isi Data Penumpang terlebih dahulu'),
              ),
            );
            return;
          }
          if (_selectedMethod == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pilih metode pembayaran terlebih dahulu'),
              ),
            );
            return;
          }

          // Label metode pembayaran yang ditampilkan di halaman struk
          final Map<String, String> methodLabels = {
            'qris': 'QRIS',
            'ovo': 'OVO',
            'bank': 'Transfer Bank',
          };

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentSuccessPage(
                vehicleImagePath: widget.vehicleImagePath,
                vehicleName: widget.vehicleName,
                seatNumber: widget.seatNumber,
                departureTime: widget.departureTime,
                arrivalTime: widget.arrivalTime,
                originCity: widget.originCity,
                destinationCity: widget.destinationCity,
                paymentMethodLabel: methodLabels[_selectedMethod] ?? '',
                ticketPrice: widget.totalPayment,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'BAYAR',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TOMBOL BATAL
  // ============================================================
  Widget _buildBatalButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: () => Navigator.of(context).maybePop(),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: primaryBlue,
          side: const BorderSide(color: primaryBlue, width: 1.2),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'BATAL',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PAINTER GARIS PUTUS-PUTUS untuk penghubung jam berangkat-tiba
// ============================================================
class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2F6BFF)
      ..strokeWidth = 2;

    const double dashWidth = 4;
    const double dashSpace = 3;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}