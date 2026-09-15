import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'akun_saya_page.dart';

class TiketSayaPage extends StatelessWidget {


  final String bookingCode;
  final String status;
  final String vehicleName;
  final String seatNumber;
  final String departureTime;
  final String arrivalTime;
  final String originCity;
  final String destinationCity;
  final int totalPrice;
  final String passengerName;

  const TiketSayaPage({
    super.key,
    this.bookingCode = 'ST3009',
    this.status = 'Lunas',
    this.vehicleName = 'HiAce Premio (CS)',
    this.seatNumber = '3',
    this.departureTime = '12.15',
    this.arrivalTime = '14.15',
    this.originCity = 'Surabaya',
    this.destinationCity = 'Malang',
    this.totalPrice = 170000,
    this.passengerName = 'Achmad Rafi Ilmal',
  });

  static const Color primaryBlue = Color(0xFF2F6BFF);
  static const Color titleColor = Color(0xFF172B4D);
  static const Color textColor = Color(0xFF6F82A5);
  static const Color borderColor = Color(0xFFE9EEF6);
  static const Color successGreen = Color(0xFF22C55E);

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
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: primaryBlue, width: 1.4)),
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
              'Tiket Saya',
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
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Riwayat Tiket',
                      style: TextStyle(
                        color: primaryBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildTicketCard(),
                    const SizedBox(height: 20),
                    _buildDownloadButton(context),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }


  Widget _buildBottomNavigation(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        height: 68,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E5E5), width: 0.7)),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: BottomNavigationBar(
              currentIndex: 1,
              onTap: (index) {
                if (index == 1) return; // sudah di halaman Tiket Saya

                if (index == 0) {
                  // Beranda: kembali langsung ke HomePage
                  Navigator.of(context).popUntil((route) => route.isFirst);
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
                  return;
                }

                if (index == 3) {
                  // Akun: langsung ganti halaman ini dengan AkunSayaPage
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const AkunSayaPage()),
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
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
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


  Widget _buildTicketCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
          // Kode pemesanan + status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kode Pemesanan: $bookingCode',
                style: const TextStyle(
                  color: titleColor,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F9EC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: successGreen,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: borderColor),
          const SizedBox(height: 14),

          // Armada + nomor kursi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                vehicleName,
                style: const TextStyle(
                  color: titleColor,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Seat No: $seatNumber',
                style: const TextStyle(
                  color: titleColor,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Keberangkatan, Tujuan, Total Harga
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _scheduleColumn(
                  label: 'Keberangkatan:',
                  time: departureTime,
                  city: originCity,
                ),
              ),
              Expanded(
                flex: 2,
                child: _buildDashedArrow(),
              ),
              Expanded(
                flex: 3,
                child: _scheduleColumn(
                  label: 'Tujuan:',
                  time: arrivalTime,
                  city: destinationCity,
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Total Harga:',
                      textAlign: TextAlign.right,
                      style: TextStyle(color: textColor, fontSize: 11),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatPrice(totalPrice),
                      textAlign: TextAlign.right,
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
          const SizedBox(height: 16),
          const Divider(height: 1, color: borderColor),
          const SizedBox(height: 14),

          // Penumpang
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Penumpang:',
                  style: TextStyle(color: textColor, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  passengerName.toUpperCase(),
                  style: const TextStyle(
                    color: titleColor,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Harap Scan Barcode di Loket',
            style: TextStyle(color: textColor, fontSize: 12),
          ),
          const SizedBox(height: 12),

          // QR Code
          QrImageView(
            data: bookingCode,
            version: QrVersions.auto,
            size: 160,
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _scheduleColumn({
    required String label,
    required String time,
    required String city,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            maxLines: 1,
            style: const TextStyle(color: textColor, fontSize: 11),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          time,
          style: const TextStyle(
            color: titleColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          city,
          style: const TextStyle(color: textColor, fontSize: 11.5),
        ),
      ],
    );
  }

  Widget _buildDashedArrow() {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: primaryBlue,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Container(
              height: 1.4,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              child: CustomPaint(painter: _DashedLinePainter()),
            ),
          ),
          const Icon(Icons.arrow_forward, size: 12, color: primaryBlue),
        ],
      ),
    );
  }


  Widget _buildDownloadButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () => _downloadTicket(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'UNDUH TIKET',
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Future<void> _downloadTicket(BuildContext context) async {
    try {
      final Uint8List pdfBytes = await _generateTicketPdf();
      await Printing.sharePdf(bytes: pdfBytes, filename: 'Tiket_$bookingCode.pdf');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat tiket: $e')),
        );
      }
    }
  }

  Future<Uint8List> _generateTicketPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a6,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'E-Tiket',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.Text('Kode Pemesanan: $bookingCode'),
              pw.Text('Status: $status'),
              pw.Divider(),
              pw.SizedBox(height: 8),
              pw.Text('$vehicleName - Seat No: $seatNumber'),
              pw.SizedBox(height: 8),
              pw.Text('Keberangkatan : $departureTime  $originCity'),
              pw.Text('Tujuan        : $arrivalTime  $destinationCity'),
              pw.SizedBox(height: 8),
              pw.Text(
                'Total Harga: ${_formatPrice(totalPrice)}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              pw.Text('Penumpang: ${passengerName.toUpperCase()}'),
              pw.SizedBox(height: 16),
              pw.Center(
                child: pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: bookingCode,
                  width: 140,
                  height: 140,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  'Harap scan barcode di loket',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2F6BFF).withOpacity(0.6)
      ..strokeWidth = 1.4;

    const double dashWidth = 3;
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
