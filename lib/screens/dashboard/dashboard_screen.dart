import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          _DashboardAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _StatsGrid(),
                const SizedBox(height: 24),
                _ActiveSeasonsCard(),
                const SizedBox(height: 24),
                _RecentPaymentsCard(),
                const SizedBox(height: 24),
                _PlaceWiseChart(),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("hello");
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(top: -30, right: -30, child: _decorCircle(120, 0.06)),
              Positioned(top: 60, right: 80, child: _decorCircle(60, 0.08)),
              Positioned(bottom: -20, left: 60, child: _decorCircle(80, 0.05)),
              // Content
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.mosque_rounded, color: AppColors.accentLight, size: 28),
                          const SizedBox(width: 10),
                          Text(
                            'مسجد مجاهد',
                            style: GoogleFonts.amiri(
                              color: AppColors.accentLight,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mahal Management Dashboard',
                        style: GoogleFonts.notoSans(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        title: Text(
          'Dashboard',
          style: GoogleFonts.amiri(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 14),
      ),
    );
  }

  Widget _decorCircle(double size, double opacity) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white.withOpacity(opacity), width: 1),
    ),
  );
}

class _StatsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, p, _) {
        final stats = [
          _Stat('Total Members', p.totalMembers.toString(), Icons.people_rounded, AppColors.primary),
          _Stat('Family Members', p.totalFamilyMembers.toString(), Icons.family_restroom_rounded, AppColors.primaryLighter),
          _Stat('Total Collected', '₹${_formatAmount(p.totalCollectedAllTime)}', Icons.account_balance_wallet_rounded, AppColors.accent),
          _Stat('Active Seasons', p.activeSeasons.length.toString(), Icons.event_rounded, AppColors.success),
        ];
        return LayoutBuilder(builder: (context, constraints) {
          final crossCount = constraints.maxWidth > 600 ? 4 : 2;
          return GridView.count(
            crossAxisCount: crossCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: constraints.maxWidth > 600 ? 1.6 : 1.5,
            children: stats.map((s) => _StatCard(stat: s)).toList(),
          );
        });
      },
    );
  }

  String _formatAmount(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

class _Stat {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _Stat(this.title, this.value, this.icon, this.color);
}

class _StatCard extends StatelessWidget {
  final _Stat stat;
  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: stat.color.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: stat.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(stat.icon, color: stat.color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(stat.value, style: GoogleFonts.amiri(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Text(stat.title, style: GoogleFonts.notoSans(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActiveSeasonsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, p, _) {
        final active = p.activeSeasons;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Active Seasons', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            if (active.isEmpty)
              _emptyCard('No active seasons')
            else
              ...active.map((s) {
                final collected = p.getTotalCollectedForSeason(s.id);
                final progress = s.targetAmount > 0 ? (collected / s.targetAmount).clamp(0.0, 1.0) : 0.0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.07), blurRadius: 12)],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(s.category, style: GoogleFonts.notoSans(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                            child: Text('Active', style: GoogleFonts.notoSans(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(s.name, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(s.description, style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('₹${collected.toStringAsFixed(0)} collected', style: GoogleFonts.notoSans(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
                          Text('Target: ₹${s.targetAmount.toStringAsFixed(0)}', style: GoogleFonts.notoSans(fontSize: 12, color: AppColors.textLight)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: AppColors.divider,
                          valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}

class _RecentPaymentsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, p, _) {
        final recent = p.payments.reversed.take(5).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Payments', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.06), blurRadius: 12)],
              ),
              child: recent.isEmpty
                  ? Padding(
                padding: const EdgeInsets.all(24),
                child: Center(child: Text('No payments yet', style: Theme.of(context).textTheme.bodyMedium)),
              )
                  : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recent.length,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 60),
                itemBuilder: (context, i) {
                  final pay = recent[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        pay.memberName.isNotEmpty ? pay.memberName[0] : '?',
                        style: GoogleFonts.amiri(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(pay.memberName, style: Theme.of(context).textTheme.titleMedium),
                    subtitle: Text('${pay.seasonName} • ${pay.formattedDate}', style: Theme.of(context).textTheme.bodySmall),
                    trailing: Text(pay.formattedAmount, style: GoogleFonts.notoSans(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 14)),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PlaceWiseChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, p, _) {
        final placeCount = <String, int>{};
        for (final m in p.members) {
          if (m.isActive) placeCount[m.housePlace] = (placeCount[m.housePlace] ?? 0) + 1;
        }
        if (placeCount.isEmpty) return const SizedBox();

        final colors = [
          AppColors.primary,
          AppColors.primaryLighter,
          AppColors.accent,
          AppColors.success,
          AppColors.warning,
          Colors.purple,
        ];
        final sections = placeCount.entries.toList().asMap().entries.map((e) {
          return PieChartSectionData(
            value: e.value.value.toDouble(),
            title: '${e.value.key}\n${e.value.value}',
            color: colors[e.key % colors.length],
            radius: 80,
            titleStyle: GoogleFonts.notoSans(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
          );
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Members by Place', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            Container(
              height: 240,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.06), blurRadius: 12)],
              ),
              padding: const EdgeInsets.all(16),
              child: PieChart(PieChartData(sections: sections, sectionsSpace: 2, centerSpaceRadius: 30)),
            ),
          ],
        );
      },
    );
  }
}

Widget _emptyCard(String msg) => Container(
  padding: const EdgeInsets.all(24),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
  ),
  child: Center(child: Text(msg, style: GoogleFonts.notoSans(color: AppColors.textLight))),
);