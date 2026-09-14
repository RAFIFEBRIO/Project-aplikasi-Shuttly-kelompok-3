import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'home_Page.dart';

class PaymentSuccessPage extends StatelessWidget {
  // ============================================================
  // DATA YANG DITAMPILKAN DI STRUK
  //
  // Semua diberi nilai default sesuai contoh desain, supaya halaman
  // ini tetap bisa dibuka langsung untuk keperluan development.
  // Nantinya nilai-nilai ini dikirim dari halaman Pembayaran.
  // ============================================================

  final String invoiceNumber;
  final String vehicleImagePath;
  final String vehicleName;
  final String vehicleSubtitle;
  final String orderDate;
  final String departureTime;
  final String arrivalTime;
  final String originCity;
  final String destinationCity;
  final String seatNumber;
  final String paymentMethodLabel;
  final int ticketPrice;
  final int additionalFee;

  const PaymentSuccessPage({
    super.key,
    this.invoiceNumber = 'INV-20250912-0001',
    this.vehicleImagePath = 'assets/images/hiace_premio.png',
    this.vehicleName = 'HiAce Premio (CS)',
    this.vehicleSubtitle = 'Toyota HiAce Premio',
    this.orderDate = '12 September 2025',
    this.departureTime = '12.15',
    this.arrivalTime = '14.15',
    this.originCity = 'Surabaya',
    this.destinationCity = 'Malang',
    this.seatNumber = '3',
    this.paymentMethodLabel = 'OVO',
    this.ticketPrice = 170000,
    this.additionalFee = 0,
  });

  static const Color titleColor = Color(0xFF172B4D);
  static const Color textColor = Color(0xFF6F82A5);
  static const Color primaryBlue = Color(0xFF2F6BFF);
  static const Color pageBg = Color(0xFFF3F5F9);
  static const Color borderColor = Color(0xFFE9EEF6);
  static const Color successGreen = Color(0xFF22C55E);

  int get totalPayment => ticketPrice + additionalFee;

  // ============================================================
  // FORMAT HARGA -> "Rp 170.000"
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    // Bagian atas kartu (icon, judul, tombol close)
                    _buildHeaderCard(context),

                    // Garis putus-putus dengan "lubang" ala tiket
                    _buildTicketNotch(),

                    // Bagian bawah kartu (isi struk)
                    _buildBodyCard(context),
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
  // KARTU ATAS: ikon sukses, judul, subjudul, tombol close (X)
  // ============================================================
  Widget _buildHeaderCard(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: Container(
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        child: Stack(
          children: [
            Column(
              children: [
                _buildSuccessIcon(),
                const SizedBox(height: 16),
                const Text(
                  'Pembayaran Berhasil',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Terima kasih! Pembayaran Anda telah berhasil diproses.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textColor, fontSize: 13, height: 1.4),
                ),
              ],
            ),
            Positioned(
              top: -4,
              right: -4,
              child: IconButton(
                onPressed: () {
                  // Tombol close: keluar dari alur pemesanan dan kembali
                  // ke halaman Beranda. pushAndRemoveUntil menghapus
                  // semua halaman sebelumnya (vehicle selection, pilih
                  // kursi, pembayaran, dst.) dari tumpukan navigasi,
                  // supaya tombol back di HomePage tidak balik lagi ke
                  // alur pemesanan yang sudah selesai.
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomePage()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.close, color: titleColor, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Ikon struk/invoice dengan badge centang hijau
  Widget _buildSuccessIcon() {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Icon(Icons.receipt_long_rounded, size: 58, color: primaryBlue),
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: successGreen,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GARIS PUTUS-PUTUS + "LUBANG" ala sobekan tiket
  // ============================================================
  Widget _buildTicketNotch() {
    return SizedBox(
      height: 24,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            height: 1,
            child: CustomPaint(painter: _DashedLinePainter()),
          ),
          Positioned(
            left: -20,
            child: _notchCircle(),
          ),
          Positioned(
            right: -20,
            child: _notchCircle(),
          ),
        ],
      ),
    );
  }

  Widget _notchCircle() {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: pageBg,
        shape: BoxShape.circle,
      ),
    );
  }

  // ============================================================
  // KARTU BAWAH: invoice, foto kendaraan, detail perjalanan,
  // rincian pembayaran, tombol download
  // ============================================================
  Widget _buildBodyCard(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      child: Container(
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInvoiceBadge(),
            const SizedBox(height: 18),
            _buildVehicleImage(),
            const SizedBox(height: 16),
            Text(
              vehicleName,
              style: const TextStyle(
                color: titleColor,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              vehicleSubtitle,
              style: const TextStyle(color: textColor, fontSize: 13),
            ),
            const SizedBox(height: 18),
            _buildTripDetailRows(),
            const SizedBox(height: 18),
            const Divider(height: 1, color: borderColor),
            const SizedBox(height: 18),
            const Text(
              'Rincian Pembayaran',
              style: TextStyle(
                color: titleColor,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodHighlight(),
            const SizedBox(height: 12),
            _buildKeyValueRow('Jenis Pembayaran', paymentMethodLabel),
            const SizedBox(height: 12),
            _buildDashedDivider(),
            const SizedBox(height: 12),
            _buildKeyValueRow('Harga Tiket', _formatPrice(ticketPrice)),
            const SizedBox(height: 8),
            _buildKeyValueRow('Biaya Tambahan', _formatPrice(additionalFee)),
            const SizedBox(height: 14),
            const Divider(height: 1, color: borderColor),
            const SizedBox(height: 14),
            _buildKeyValueRow(
              'Total Pembayaran',
              _formatPrice(totalPayment),
              boldLabel: true,
              valueFontSize: 17,
            ),
            const SizedBox(height: 22),
            _buildDownloadButton(context),
          ],
        ),
      ),
    );
  }

  // Badge nomor invoice + status "Berhasil"
  Widget _buildInvoiceBadge() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.description_outlined, color: primaryBlue, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Invoice Number',
                  style: TextStyle(color: textColor, fontSize: 11.5),
                ),
                const SizedBox(height: 2),
                Text(
                  invoiceNumber,
                  style: const TextStyle(
                    color: titleColor,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F9EC),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: successGreen, size: 15),
                SizedBox(width: 4),
                Text(
                  'Berhasil',
                  style: TextStyle(
                    color: successGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        height: 170,
        color: const Color(0xFFF0F3F7),
        child: Image.asset(
          vehicleImagePath,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.directions_car_filled_rounded,
              color: primaryBlue.withOpacity(0.4),
              size: 50,
            );
          },
        ),
      ),
    );
  }

  // Baris Tanggal & Waktu, Keberangkatan, Tujuan, Nomor Seat
  Widget _buildTripDetailRows() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _iconInfoTile(
          icon: Icons.calendar_today_outlined,
          label: 'Tanggal & Waktu',
          value: '$orderDate, $departureTime - $arrivalTime',
        ),
        const SizedBox(height: 16),
        Padding(
          // Sedikit inset di kanan supaya blok "Tujuan" tidak mepet
          // pas di tepi kartu, terlihat lebih rapi.
          padding: const EdgeInsets.only(right: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _iconInfoTile(
                icon: Icons.location_on_outlined,
                label: 'Keberangkatan',
                value: originCity,
                fitContent: true,
              ),
              // Blok ikon+teks "Tujuan" didorong rata ke pojok kanan lewat
              // MainAxisAlignment.spaceBetween pada Row induk di atas.
              _iconInfoTile(
                icon: Icons.location_on_outlined,
                label: 'Tujuan',
                value: destinationCity,
                fitContent: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _iconInfoTile(
          icon: Icons.event_seat_outlined,
          label: 'Nomor Seat',
          value: 'NO.$seatNumber',
        ),
      ],
    );
  }

  Widget _iconInfoTile({
    required IconData icon,
    required String label,
    required String value,
    bool fitContent = false,
  }) {
    final Widget textColumn = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // FittedBox membuat teks label otomatis mengecil kalau
        // ruangnya sempit, sehingga kata "Keberangkatan" tetap
        // utuh dalam satu baris (tidak terpotong "...").
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            maxLines: 1,
            style: const TextStyle(color: textColor, fontSize: 11),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: titleColor,
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
        ),
      ],
    );

    return Row(
      mainAxisSize: fitContent ? MainAxisSize.min : MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: primaryBlue),
        const SizedBox(width: 8),
        fitContent ? textColumn : Expanded(child: textColumn),
      ],
    );
  }

  // Kotak highlight "Metode Pembayaran" berisi ikon + nama metode
  Widget _buildPaymentMethodHighlight() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F0FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Metode Pembayaran',
            style: TextStyle(color: textColor, fontSize: 13),
          ),
          _buildPaymentMethodBadge(),
        ],
      ),
    );
  }

  // Logo metode pembayaran (disesuaikan dengan label yang dikirim)
  Widget _buildPaymentMethodBadge() {
    final String method = paymentMethodLabel.toLowerCase();

    IconData icon;
    Color color;
    if (method.contains('qris')) {
      icon = Icons.qr_code_2;
      color = const Color(0xFFE23744);
    } else if (method.contains('ovo')) {
      icon = Icons.circle;
      color = const Color(0xFF4C2A86);
    } else {
      icon = Icons.account_balance;
      color = const Color(0xFF0060AF);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 6),
        Text(
          paymentMethodLabel,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildKeyValueRow(
    String label,
    String value, {
    bool boldLabel = false,
    double valueFontSize = 13.5,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: boldLabel ? titleColor : textColor,
            fontSize: 13.5,
            fontWeight: boldLabel ? FontWeight.w800 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: titleColor,
            fontSize: valueFontSize,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildDashedDivider() {
    return SizedBox(
      width: double.infinity,
      height: 1,
      child: CustomPaint(painter: _DashedLinePainter(color: borderColor)),
    );
  }

  Widget _buildDownloadButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () => _downloadInvoice(context),
        icon: const Icon(Icons.download_rounded, size: 20),
        label: const Text(
          'Download PDF Invoice',
          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PROSES DOWNLOAD PDF INVOICE
  //
  // 1. Bangun dokumen PDF berisi rincian pesanan & pembayaran.
  // 2. Buka dialog simpan/bagikan lewat package `printing`
  //    (Printing.sharePdf) — ini yang membuat tombol "download"
  //    beneran berfungsi: di HP akan membuka share sheet (bisa
  //    disimpan ke file/Drive/WhatsApp dll), di desktop/web akan
  //    langsung men-download file PDF-nya.
  // ============================================================
  Future<void> _downloadInvoice(BuildContext context) async {
    try {
      final Uint8List pdfBytes = await _generateInvoicePdf();
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: '$invoiceNumber.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat PDF: $e')),
        );
      }
    }
  }

  // Menyusun isi dokumen PDF invoice
  Future<Uint8List> _generateInvoicePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Invoice Pembayaran',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text('No. Invoice: $invoiceNumber'),
              pw.SizedBox(height: 4),
              pw.Text(
                'Status: Berhasil',
                style: pw.TextStyle(
                  color: PdfColors.green700,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Divider(),
              pw.SizedBox(height: 12),

              _pdfSectionTitle('Detail Kendaraan'),
              pw.Text(vehicleName),
              pw.Text(vehicleSubtitle),
              pw.SizedBox(height: 12),

              _pdfSectionTitle('Detail Perjalanan'),
              pw.Text('Tanggal        : $orderDate'),
              pw.Text('Waktu          : $departureTime - $arrivalTime'),
              pw.Text('Rute           : $originCity -> $destinationCity'),
              pw.Text('Nomor Seat     : $seatNumber'),
              pw.SizedBox(height: 12),

              _pdfSectionTitle('Rincian Pembayaran'),
              pw.Text('Metode Pembayaran : $paymentMethodLabel'),
              pw.SizedBox(height: 6),
              _pdfRow('Harga Tiket', _formatPrice(ticketPrice)),
              _pdfRow('Biaya Tambahan', _formatPrice(additionalFee)),
              pw.Divider(),
              _pdfRow(
                'Total Pembayaran',
                _formatPrice(totalPayment),
                bold: true,
              ),

              pw.SizedBox(height: 24),
              pw.Text(
                'Terima kasih telah menggunakan layanan kami.',
                style: pw.TextStyle(
                  fontSize: 11,
                  color: PdfColors.grey600,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _pdfSectionTitle(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  pw.Widget _pdfRow(String label, String value, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontSize: bold ? 13 : 11,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontSize: bold ? 13 : 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PAINTER GARIS PUTUS-PUTUS (dipakai di beberapa tempat)
// ============================================================
class _DashedLinePainter extends CustomPainter {
  final Color color;
  const _DashedLinePainter({this.color = const Color(0xFFCBD5E1)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4;

    const double dashWidth = 4;
    const double dashSpace = 4;
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