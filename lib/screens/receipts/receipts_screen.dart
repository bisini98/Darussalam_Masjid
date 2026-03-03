import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import 'receipt_screen.dart';

class ReceiptsScreen extends StatefulWidget {
  const ReceiptsScreen({super.key});

  @override
  State<ReceiptsScreen> createState() => _ReceiptsScreenState();
}

class _ReceiptsScreenState extends State<ReceiptsScreen> {
  String _search = '';
  String _selectedSeason = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Receipts'),
        backgroundColor: AppColors.primary,
      ),
      body: Consumer<AppProvider>(
        builder: (context, p, _) {
          var payments = p.payments.reversed.toList();
          if (_selectedSeason != 'All') {
            payments = payments.where((pay) => pay.seasonName == _selectedSeason).toList();
          }
          if (_search.isNotEmpty) {
            final q = _search.toLowerCase();
            payments = payments.where((pay) =>
            pay.memberName.toLowerCase().contains(q) ||
                pay.receiptNumber.toLowerCase().contains(q)).toList();
          }

          final seasonNames = ['All', ...{...p.payments.map((pay) => pay.seasonName)}];

          return Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  children: [
                    TextField(
                      onChanged: (v) => setState(() => _search = v),
                      decoration: const InputDecoration(
                        hintText: 'Search by name or receipt no...',
                        prefixIcon: Icon(Icons.search_rounded, color: AppColors.textLight),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: seasonNames.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final s = seasonNames[i];
                          final sel = _selectedSeason == s;
                          return FilterChip(
                            label: Text(s, style: GoogleFonts.notoSans(fontSize: 12, fontWeight: sel ? FontWeight.w600 : FontWeight.normal, color: sel ? Colors.white : AppColors.textPrimary)),
                            selected: sel,
                            onSelected: (_) => setState(() => _selectedSeason = s),
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.surfaceDark,
                            checkmarkColor: Colors.white,
                            side: BorderSide.none,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Summary bar
              Container(
                color: AppColors.primary.withOpacity(0.05),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Text('${payments.length} receipts', style: GoogleFonts.notoSans(fontSize: 13, color: AppColors.textSecondary)),
                    const Spacer(),
                    Text(
                      'Total: ₹${payments.fold(0.0, (s, p) => s + p.amount).toStringAsFixed(0)}',
                      style: GoogleFonts.notoSans(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: payments.isEmpty
                    ? Center(child: Text('No receipts found.', style: Theme.of(context).textTheme.bodyLarge))
                    : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: payments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final pay = payments[i];
                    final member = p.getMember(pay.memberId);
                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: member == null
                          ? null
                          : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReceiptScreen(payment: pay, member: member),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 8)],
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(pay.memberName, style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 2),
                                  Text(pay.receiptNumber, style: GoogleFonts.notoSans(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500)),
                                  Text('${pay.seasonName} • ${pay.formattedDate}', style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(pay.formattedAmount, style: GoogleFonts.amiri(color: AppColors.success, fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                if (member != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
                                    child: Text('View', style: GoogleFonts.notoSans(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}