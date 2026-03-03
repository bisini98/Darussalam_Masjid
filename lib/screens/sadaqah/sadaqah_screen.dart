import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/sadaqah.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import 'add_payment_dialog.dart';

class SadaqahScreen extends StatefulWidget {
  const SadaqahScreen({super.key});

  @override
  State<SadaqahScreen> createState() => _SadaqahScreenState();
}

class _SadaqahScreenState extends State<SadaqahScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Sadaqah Management'),
        backgroundColor: AppColors.primary,
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppColors.accentLight,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Seasons'),
            Tab(text: 'All Payments'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          _SeasonsTab(),
          _PaymentsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSeason(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('New Season', style: GoogleFonts.notoSans(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _showAddSeason(BuildContext context) {
    showDialog(context: context, builder: (_) => const _AddSeasonDialog());
  }
}

class _SeasonsTab extends StatelessWidget {
  const _SeasonsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, p, _) {
        final seasons = p.seasons;
        if (seasons.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_rounded, size: 64, color: AppColors.textLight),
                const SizedBox(height: 12),
                Text('No seasons yet. Create one!', style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: seasons.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) => _SeasonCard(season: seasons[i]),
        );
      },
    );
  }
}

class _SeasonCard extends StatelessWidget {
  final SadaqahSeason season;
  const _SeasonCard({required this.season});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, p, _) {
        final collected = p.getTotalCollectedForSeason(season.id);
        final paymentCount = p.getPaymentsBySeason(season.id).length;
        final progress = season.targetAmount > 0 ? (collected / season.targetAmount).clamp(0.0, 1.0) : 0.0;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.07), blurRadius: 12)],
          ),
          child: Column(
            children: [
              // Header
              Container(
                decoration: BoxDecoration(
                  gradient: season.isActive ? AppColors.primaryGradient : const LinearGradient(colors: [Color(0xFF9CA3AF), Color(0xFF6B7280)]),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(season.name, style: GoogleFonts.amiri(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(season.category, style: GoogleFonts.notoSans(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        season.isActive ? 'Active' : 'Closed',
                        style: GoogleFonts.notoSans(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              // Body
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(season.description, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _stat('Collected', '₹${collected.toStringAsFixed(0)}', AppColors.success),
                        _stat('Target', '₹${season.targetAmount.toStringAsFixed(0)}', AppColors.primary),
                        _stat('Payments', '$paymentCount', AppColors.accent),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (season.targetAmount > 0) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${(progress * 100).toStringAsFixed(1)}% achieved', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: AppColors.divider,
                          valueColor: const AlwaysStoppedAnimation(AppColors.success),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    // Member payment status
                    _MemberPaymentStatus(season: season),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _stat(String label, String value, Color color) => Column(
    children: [
      Text(value, style: GoogleFonts.amiri(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      Text(label, style: GoogleFonts.notoSans(fontSize: 11, color: AppColors.textSecondary)),
    ],
  );
}

class _MemberPaymentStatus extends StatelessWidget {
  final SadaqahSeason season;
  const _MemberPaymentStatus({required this.season});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, p, _) {
        final members = p.members.where((m) => m.isActive).toList();
        final paid = members.where((m) => p.hasMemberPaidForSeason(m.id, season.id)).length;
        final unpaid = members.length - paid;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Member Status', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                _badge('$paid Paid', AppColors.success),
                const SizedBox(width: 8),
                _badge('$unpaid Pending', AppColors.warning),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: members.length > 10 ? 10 : members.length,
                separatorBuilder: (_, __) => const SizedBox(width: 4),
                itemBuilder: (context, i) {
                  final m = members[i];
                  final hasPaid = p.hasMemberPaidForSeason(m.id, season.id);
                  return InkWell(
                    onTap: hasPaid ? null : () => showDialog(context: context, builder: (_) => AddPaymentDialog(member: m, preselectedSeasonId: season.id)),
                    child: Tooltip(
                      message: m.name,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: hasPaid ? AppColors.success.withOpacity(0.2) : AppColors.warning.withOpacity(0.2),
                        child: Text(m.initials, style: GoogleFonts.amiri(fontSize: 10, color: hasPaid ? AppColors.success : AppColors.warning, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (members.length > 10)
              Text('+ ${members.length - 10} more members', style: Theme.of(context).textTheme.bodySmall),
          ],
        );
      },
    );
  }

  Widget _badge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
    child: Text(label, style: GoogleFonts.notoSans(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
  );
}

class _PaymentsTab extends StatelessWidget {
  const _PaymentsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, p, _) {
        final payments = p.payments.reversed.toList();
        if (payments.isEmpty) {
          return Center(child: Text('No payments recorded yet.', style: Theme.of(context).textTheme.bodyLarge));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: payments.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final pay = payments[i];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 8)],
              ),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(pay.memberName[0], style: GoogleFonts.amiri(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(pay.memberName, style: Theme.of(context).textTheme.titleMedium),
                        Text('${pay.seasonName} • ${pay.formattedDate}', style: Theme.of(context).textTheme.bodySmall),
                        Text(pay.receiptNumber, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primary)),
                      ],
                    ),
                  ),
                  Text(pay.formattedAmount, style: GoogleFonts.amiri(color: AppColors.success, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ─── Add Season Dialog ─────────────────────────────────────────
class _AddSeasonDialog extends StatefulWidget {
  const _AddSeasonDialog();

  @override
  State<_AddSeasonDialog> createState() => _AddSeasonDialogState();
}

class _AddSeasonDialogState extends State<_AddSeasonDialog> {
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _target = TextEditingController();
  String _category = 'General Sadaqah';
  final _categories = ['General Sadaqah', 'Zakat', 'Zakat Fitrah', 'Waqf', 'Special Collection'];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Create New Season', style: GoogleFonts.amiri(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _name, decoration: const InputDecoration(hintText: 'Season Name (e.g. Ramadan 1447)', prefixIcon: Icon(Icons.event_rounded))),
            const SizedBox(height: 12),
            TextField(controller: _desc, decoration: const InputDecoration(hintText: 'Description', prefixIcon: Icon(Icons.description_rounded)), maxLines: 2),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _category,
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _category = v!),
              decoration: const InputDecoration(prefixIcon: Icon(Icons.category_rounded)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _target,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Target Amount (₹)', prefixIcon: Icon(Icons.account_balance_wallet_rounded)),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_name.text.isEmpty) return;
            final p = Provider.of<AppProvider>(context, listen: false);
            p.addSeason(SadaqahSeason(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: _name.text,
              description: _desc.text,
              startDate: DateTime.now(),
              targetAmount: double.tryParse(_target.text) ?? 0,
              category: _category,
            ));
            Navigator.pop(context);
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}