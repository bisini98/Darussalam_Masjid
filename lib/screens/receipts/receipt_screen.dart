import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/member.dart';
import '../../models/sadaqah.dart';
import '../../theme/app_theme.dart';

class ReceiptScreen extends StatelessWidget {
  final SadaqahPayment payment;
  final Member member;
  const ReceiptScreen({super.key, required this.payment, required this.member});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Receipt'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.print_rounded, color: Colors.white),
            onPressed: () => _printReceipt(context),
            tooltip: 'Print / Download',
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            onPressed: () => _printReceipt(context),
            tooltip: 'Download PDF',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _ReceiptCard(payment: payment, member: member),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _printReceipt(context),
                    icon: const Icon(Icons.print_rounded),
                    label: const Text('Print Receipt'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _printReceipt(context),
                    icon: const Icon(Icons.download_rounded, color: AppColors.primary),
                    label: Text('Download PDF', style: GoogleFonts.notoSans(color: AppColors.primary)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _printReceipt(BuildContext context) async {
    final pdf = await _buildPdf();
    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  Future<pw.Document> _buildPdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Container(
              width: double.infinity,
              color: PdfColor.fromHex('#1B4332'),
              padding: const pw.EdgeInsets.all(20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text('مسجد مجاهد', style: pw.TextStyle(fontSize: 22, color: PdfColor.fromHex('#E9C46A'), fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text('MUJAHID MASJID', style: pw.TextStyle(fontSize: 14, color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 2),
                  pw.Text('Official Sadaqah Receipt', style: pw.TextStyle(fontSize: 10, color: PdfColors.white)),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
            // Receipt number & date
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Receipt No: ${payment.receiptNumber}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('Date: ${payment.formattedDate}'),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Divider(),
            pw.SizedBox(height: 10),
            // Member info
            _pdfRow('Name:', member.name),
            _pdfRow('Phone:', member.phone),
            _pdfRow('House No:', member.houseNumber),
            _pdfRow('Place:', member.housePlace),
            pw.SizedBox(height: 10),
            pw.Divider(),
            pw.SizedBox(height: 10),
            // Payment info
            _pdfRow('Season:', payment.seasonName),
            _pdfRow('Amount Paid:', payment.formattedAmount),
            _pdfRow('Payment Status:', payment.status.name.toUpperCase()),
            if (payment.adminNote.isNotEmpty) _pdfRow('Notes:', payment.adminNote),
            pw.SizedBox(height: 16),
            pw.Divider(),
            pw.SizedBox(height: 16),
            // Amount box
            pw.Container(
              width: double.infinity,
              color: PdfColor.fromHex('#F5F3EE'),
              padding: const pw.EdgeInsets.all(16),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text('Amount Received', style: pw.TextStyle(fontSize: 11, color: PdfColors.grey)),
                  pw.SizedBox(height: 6),
                  pw.Text(payment.formattedAmount, style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1B4332'))),
                ],
              ),
            ),
            pw.Spacer(),
            // Footer
            pw.Divider(),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Authorized Signature', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                    pw.SizedBox(height: 20),
                    pw.Text('____________________', style: pw.TextStyle(fontSize: 10)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('BarakAllahu Feekum', style: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#D4A017'), fontStyle: pw.FontStyle.italic)),
                    pw.Text('Mujahid Masjid', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
    return pdf;
  }

  pw.Widget _pdfRow(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 3),
    child: pw.Row(
      children: [
        pw.SizedBox(width: 120, child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11))),
        pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
      ],
    ),
  );
}

class _ReceiptCard extends StatelessWidget {
  final SadaqahPayment payment;
  final Member member;
  const _ReceiptCard({required this.payment, required this.member});

  @override
  Widget build(BuildContext context) {
    final maxW = MediaQuery.of(context).size.width;
    return Container(
      width: maxW > 500 ? 420 : double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.12), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(Icons.mosque_rounded, color: AppColors.accentLight, size: 40),
                const SizedBox(height: 8),
                Text('مسجد مجاهد', style: GoogleFonts.amiri(color: AppColors.accentLight, fontSize: 22, fontWeight: FontWeight.bold)),
                Text('MUJAHID MASJID', style: GoogleFonts.notoSans(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
                const SizedBox(height: 4),
                Text('Official Sadaqah Receipt', style: GoogleFonts.notoSans(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          // Receipt No + Date bar
          Container(
            color: AppColors.surfaceDark,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(payment.receiptNumber, style: GoogleFonts.notoSans(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13)),
                Text(payment.formattedDate, style: GoogleFonts.notoSans(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _section('Member Details'),
                _row('Name', member.name),
                _row('Phone', member.phone),
                _row('House No.', member.houseNumber),
                _row('Place', member.housePlace),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                _section('Payment Details'),
                _row('Season', payment.seasonName),
                _row('Status', payment.status.name.toUpperCase()),
                if (payment.adminNote.isNotEmpty) _row('Notes', payment.adminNote),
                const SizedBox(height: 16),
                // Amount box
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text('Amount Received', style: GoogleFonts.notoSans(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 6),
                      Text(payment.formattedAmount, style: GoogleFonts.amiri(color: AppColors.primary, fontSize: 32, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Footer
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Authorized Signature', style: GoogleFonts.notoSans(color: AppColors.textLight, fontSize: 11)),
                        const SizedBox(height: 20),
                        Container(width: 120, height: 1, color: AppColors.divider),
                      ],
                    ),
                    Text('BarakAllahu Feekum', style: GoogleFonts.amiri(color: AppColors.accent, fontSize: 13, fontStyle: FontStyle.italic)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: GoogleFonts.amiri(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
    ),
  );

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 100, child: Text(label, style: GoogleFonts.notoSans(fontSize: 12, color: AppColors.textSecondary))),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: GoogleFonts.notoSans(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500))),
      ],
    ),
  );
}