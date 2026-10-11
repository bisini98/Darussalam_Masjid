
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/member.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../models/ledger.dart';
const _newCategory = '__new__';

class PaymentDialog extends StatefulWidget {
  final Member member;
  final Payment? existing; // set when editing
  final String? presetMonth; // e.g. '2026-10' when a month box was tapped
  const PaymentDialog({super.key, required this.member, this.existing, this.presetMonth});

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  late final TextEditingController _amount;
  late final TextEditingController _receipt;
  late final TextEditingController _note;
  late String _categoryId;
  late DateTime _date;
  late final Set<String> _months;
  int _year = DateTime.now().year;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    final p = context.read<AppProvider>();
    _amount = TextEditingController(text: e == null ? '' : e.amount.toStringAsFixed(0));
    _receipt = TextEditingController(text: e?.receiptNo ?? '');
    _note = TextEditingController(text: e?.note ?? '');
    _categoryId = e?.categoryId ?? 'subscription';
    _date = e?.date ?? DateTime.now();
    _months = {...?e?.months};
    if (widget.presetMonth != null) {
      _months.add(widget.presetMonth!);
      _year = int.parse(widget.presetMonth!.substring(0, 4));
      _amount.text = p.monthlyRate(widget.member.id).toStringAsFixed(0);
    } else if (_months.isNotEmpty) {
      _year = int.parse(_months.first.substring(0, 4));
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _receipt.dispose();
    _note.dispose();
    super.dispose();
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<String?> _askCategoryName() {
    final c = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New category'),
        content: TextField(
          controller: c,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. Kit, Meat, Rice, Zakat'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, c.text), child: const Text('Add')),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2018),
      lastDate: DateTime(2035),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amount.text.trim());
    if (amount == null || amount <= 0) {
      _snack('Enter a valid amount');
      return;
    }
    final p = context.read<AppProvider>();
    final months = _months.toList()..sort();
    final pay = Payment(
      id: widget.existing?.id ?? const Uuid().v4(),
      memberId: widget.member.id,
      categoryId: _categoryId,
      amount: amount,
      date: _date,
      receiptNo: _receipt.text.trim(),
      note: _note.text.trim(),
      months: _categoryId == 'subscription' ? months : [],
      source: widget.existing?.source ?? 'app',
    );
    setState(() => _saving = true);
    try {
      if (widget.existing == null) {
        await p.addLedgerPayment(pay);
      } else {
        await p.updateLedgerPayment(pay);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _snack('Could not save. Check internet and try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final cats = p.categories;
    final isSub = _categoryId == 'subscription';
    final paidElsewhere = p.paidMonths(widget.member.id)
      ..removeAll(widget.existing?.months ?? const <String>[]);
    final amount = double.tryParse(_amount.text.trim()) ?? 0;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.existing == null ? 'Record Payment' : 'Edit Payment',
              style: GoogleFonts.amiri(fontWeight: FontWeight.bold, fontSize: 18)),
          Text('#${widget.member.id}  ${widget.member.name}',
              style: GoogleFonts.notoSans(fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (p.testMode)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('TEST MODE: this will NOT be saved to Firebase.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              DropdownButtonFormField<String>(
                value: cats.any((c) => c.id == _categoryId) ? _categoryId : null,
                decoration: const InputDecoration(labelText: 'Category'),
                items: [
                  ...cats.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                  const DropdownMenuItem(value: _newCategory, child: Text('+ Add new category...')),
                ],
                onChanged: (v) async {
                  if (v == _newCategory) {
                    final name = await _askCategoryName();
                    if (!mounted) return;
                    if (name != null && name.trim().isNotEmpty) {
                      final id = context.read<AppProvider>().addCategory(name);
                      setState(() => _categoryId = id);
                    }
                  } else if (v != null) {
                    setState(() => _categoryId = v);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amount,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: 'Amount (₹)', prefixIcon: Icon(Icons.currency_rupee_rounded)),
              ),
              if (isSub) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text('Months paid', style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      onPressed: () => setState(() => _year--),
                    ),
                    Text('$_year', style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded),
                      onPressed: () => setState(() => _year++),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (var m = 1; m <= 12; m++)
                      Builder(builder: (_) {
                        final key = '$_year-${m.toString().padLeft(2, '0')}';
                        final alreadyPaid = paidElsewhere.contains(key);
                        return FilterChip(
                          label: Text(DateFormat('MMM').format(DateTime(2000, m))),
                          selected: _months.contains(key) || alreadyPaid,
                          onSelected: alreadyPaid
                              ? null
                              : (v) => setState(() => v ? _months.add(key) : _months.remove(key)),
                        );
                      }),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _months.isEmpty
                            ? 'No months selected (recorded as a plain amount)'
                            : '${_months.length} month(s)'
                            '${amount > 0 ? ' • ₹${(amount / _months.length).toStringAsFixed(0)} each' : ''}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    TextButton(
                      onPressed: amount <= 0
                          ? null
                          : () {
                        final list = p.suggestMonths(widget.member.id, amount,
                            rate: p.monthlyRate(widget.member.id));
                        setState(() {
                          _months
                            ..clear()
                            ..addAll(list);
                          if (list.isNotEmpty) _year = int.parse(list.first.substring(0, 4));
                        });
                      },
                      child: const Text('Fill months from amount'),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today_rounded, size: 16),
                label: Text('Date: ${DateFormat('dd MMM yyyy').format(_date)}'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _receipt,
                decoration: const InputDecoration(labelText: 'Receipt / Book No (optional)', prefixIcon: Icon(Icons.receipt_long_rounded)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _note,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Note (optional)', prefixIcon: Icon(Icons.note_rounded)),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Save'),
        ),
      ],
    );
  }
}