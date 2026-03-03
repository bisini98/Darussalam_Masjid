import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/member.dart';
import '../../models/sadaqah.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';

class AddPaymentDialog extends StatefulWidget {
  final Member member;
  final String? preselectedSeasonId;
  const AddPaymentDialog({super.key, required this.member, this.preselectedSeasonId});

  @override
  State<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<AddPaymentDialog> {
  final _amount = TextEditingController();
  final _notes = TextEditingController();
  String? _selectedSeasonId;
  PaymentStatus _status = PaymentStatus.paid;

  @override
  void initState() {
    super.initState();
    _selectedSeasonId = widget.preselectedSeasonId;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, p, _) {
        final seasons = p.seasons;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Record Payment', style: GoogleFonts.amiri(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(widget.member.name, style: GoogleFonts.notoSans(fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Season selector
                if (seasons.isEmpty)
                  Text('No seasons available. Create a season first.', style: Theme.of(context).textTheme.bodyMedium)
                else ...[
                  Text('Season', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedSeasonId,
                    hint: const Text('Select Season'),
                    items: seasons.map((s) => DropdownMenuItem(value: s.id, child: Text('${s.name} (${s.category})'))).toList(),
                    onChanged: (v) => setState(() => _selectedSeasonId = v),
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.event_rounded)),
                  ),
                  const SizedBox(height: 12),
                  Text('Amount (₹)', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _amount,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(hintText: 'Enter amount', prefixIcon: Icon(Icons.account_balance_wallet_rounded)),
                  ),
                  const SizedBox(height: 12),
                  Text('Status', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  SegmentedButton<PaymentStatus>(
                    segments: const [
                      ButtonSegment(value: PaymentStatus.paid, label: Text('Paid'), icon: Icon(Icons.check_circle_rounded, size: 16)),
                      ButtonSegment(value: PaymentStatus.partial, label: Text('Partial'), icon: Icon(Icons.pending_rounded, size: 16)),
                    ],
                    selected: {_status},
                    onSelectionChanged: (s) => setState(() => _status = s.first),
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) return AppColors.primary;
                        return null;
                      }),
                      foregroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) return Colors.white;
                        return AppColors.textPrimary;
                      }),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notes,
                    decoration: const InputDecoration(hintText: 'Admin notes (optional)', prefixIcon: Icon(Icons.note_rounded)),
                    maxLines: 2,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: seasons.isEmpty ? null : _save,
              child: const Text('Record Payment'),
            ),
          ],
        );
      },
    );
  }

  void _save() {
    final p = Provider.of<AppProvider>(context, listen: false);
    if (_selectedSeasonId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a season')));
      return;
    }
    final amount = double.tryParse(_amount.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid amount')));
      return;
    }
    final season = p.getSeason(_selectedSeasonId!);
    final receiptNum = 'MAS/${DateTime.now().millisecondsSinceEpoch % 100000}';

    p.addPayment(SadaqahPayment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      memberId: widget.member.id,
      memberName: widget.member.name,
      seasonId: _selectedSeasonId!,
      seasonName: season?.name ?? '',
      amount: amount,
      status: _status,
      receiptNumber: receiptNum,
      adminNote: _notes.text,
    ));

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment recorded! Receipt: $receiptNum'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}