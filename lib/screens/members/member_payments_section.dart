
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../receipts/receipt_screen.dart';
import 'payment_dialog.dart';
import '../../models/member.dart';
import '../../models/ledger.dart';

class MemberPaymentsSection extends StatefulWidget {
  final Member member;
  const MemberPaymentsSection({super.key, required this.member});

  @override
  State<MemberPaymentsSection> createState() => _MemberPaymentsSectionState();
}

class _MemberPaymentsSectionState extends State<MemberPaymentsSection> {
  bool _loading = true;
  String? _error;
  int _year = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<AppProvider>().loadPaymentsFor(widget.member.id);
    } catch (e) {
      _error = 'Could not load payments. Check internet and try again.';
    }
    if (mounted) setState(() => _loading = false);
  }

  String _monthLabel(String key) => DateFormat('MMM yyyy').format(DateTime.parse('$key-01'));

  Future<void> _delete(AppProvider p, Payment pay) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this payment?'),
        content: Text('₹${pay.amount.toStringAsFixed(0)} on ${DateFormat('dd MMM yyyy').format(pay.date)}'
            '${p.testMode ? '\n\n(Test mode: nothing is deleted from Firebase)' : ''}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await p.deleteLedgerPayment(pay);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not delete. Try again.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final m = widget.member;
    final payments = p.paymentsOf(m.id);
    final paid = p.paidMonths(m.id);
    final dues = p.dueMonths(m.id);
    final now = DateTime.now();
    final kit = '${m.extras['kit'] ?? ''}'.trim();
    final beef = m.extras['beef2026'] == true;

    String catName(String id) => p.categories
        .firstWhere((c) => c.id == id, orElse: () => PayCategory(id: id, name: id))
        .name;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.06), blurRadius: 12)],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.payments_rounded, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text('Payments & Receipts', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              TextButton.icon(
                onPressed: () => showDialog(context: context, builder: (_) => PaymentDialog(member: m)),
                icon: const Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
                label: Text('Add', style: GoogleFonts.notoSans(color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          if (p.testMode)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 6, bottom: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: const Text('TEST MODE: changes are NOT saved to Firebase. Turn it off in the Categories tab.',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          const Divider(height: 20),
          // Summary
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              Chip(
                label: Text(dues.isEmpty ? 'All paid up to now' : '${dues.length} month(s) due since Jan 2026'),
                backgroundColor: (dues.isEmpty ? AppColors.success : AppColors.warning).withOpacity(0.12),
                side: BorderSide.none,
              ),
              if (kit.isNotEmpty) Chip(label: Text('Kit: $kit'), side: BorderSide.none),
              if (beef) const Chip(label: Text('Beef 2026: Yes'), side: BorderSide.none),
            ],
          ),
          const SizedBox(height: 8),
          // Month grid
          Row(
            children: [
              Text('Monthly subscription', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              IconButton(icon: const Icon(Icons.chevron_left_rounded), onPressed: () => setState(() => _year--)),
              Text('$_year', style: const TextStyle(fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.chevron_right_rounded), onPressed: () => setState(() => _year++)),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var mo = 1; mo <= 12; mo++)
                Builder(builder: (_) {
                  final key = '$_year-${mo.toString().padLeft(2, '0')}';
                  final isPaid = paid.contains(key);
                  final isDue = !isPaid && !DateTime(_year, mo).isAfter(DateTime(now.year, now.month));
                  final color = isPaid ? AppColors.success : (isDue ? AppColors.warning : AppColors.textLight);
                  final amt = m.legacyMonths[key];
                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: isPaid
                        ? null
                        : () => showDialog(
                      context: context,
                      builder: (_) => PaymentDialog(member: m, presetMonth: key),
                    ),
                    child: Container(
                      width: 66,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: color.withOpacity(0.4)),
                      ),
                      child: Column(
                        children: [
                          Text(DateFormat('MMM').format(DateTime(2000, mo)),
                              style: TextStyle(fontWeight: FontWeight.w600, color: color)),
                          Text(isPaid ? (amt != null ? '₹${amt.toStringAsFixed(0)}' : 'Paid') : (isDue ? 'Due' : '-'),
                              style: TextStyle(fontSize: 11, color: color)),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
          const SizedBox(height: 4),
          Text('Tap a month that is not paid to record it.', style: Theme.of(context).textTheme.bodySmall),
          const Divider(height: 28),
          // Receipts list
          Text('Receipts (${payments.length})', style: Theme.of(context).textTheme.titleMedium),
          if (_loading) const Padding(padding: EdgeInsets.only(top: 8), child: LinearProgressIndicator()),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(children: [
                Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.error))),
                TextButton(onPressed: _load, child: const Text('Retry')),
              ]),
            ),
          if (!_loading && _error == null && payments.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('No payments recorded yet.', style: Theme.of(context).textTheme.bodyMedium),
            ),
          ...payments.map((pay) {
            final months = pay.months.map(_monthLabel).join(', ');
            return ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReceiptScreen(payment: pay.toReceipt(m.name, catName(pay.categoryId)), member: m),
                ),
              ),
              leading: const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0x1A2D6A4F),
                child: Icon(Icons.receipt_long_rounded, size: 18, color: AppColors.primary),
              ),
              title: Text('${catName(pay.categoryId)}  •  ₹${pay.amount.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.titleMedium),
              subtitle: Text(
                '${DateFormat('dd MMM yyyy').format(pay.date)}'
                    '  •  Receipt ${pay.receiptNo.isEmpty ? '-' : pay.receiptNo}'
                    '${months.isEmpty ? '' : '\n$months'}'
                    '${pay.note.isEmpty ? '' : '\n${pay.note}'}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              isThreeLine: months.isNotEmpty || pay.note.isNotEmpty,
              trailing: PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'receipt') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReceiptScreen(payment: pay.toReceipt(m.name, catName(pay.categoryId)), member: m),
                      ),
                    );
                  } else if (v == 'edit') {
                    showDialog(context: context, builder: (_) => PaymentDialog(member: m, existing: pay));
                  } else if (v == 'delete') {
                    _delete(p, pay);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'receipt', child: Text('View / print receipt')),
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}