import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/member.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import 'add_edit_member_screen.dart';
import '../sadaqah/add_payment_dialog.dart';
import '../receipts/receipt_screen.dart';
import 'member_payments_section.dart';

class MemberDetailScreen extends StatelessWidget {
  final String memberId;
  const MemberDetailScreen({super.key, required this.memberId});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, p, _) {
        final member = p.getMember(memberId);
        if (member == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Member Not Found')),
            body: const Center(child: Text('This member no longer exists.')),
          );
        }
        return _MemberDetailView(member: member);
      },
    );
  }
}

class _MemberDetailView extends StatelessWidget {
  final Member member;
  const _MemberDetailView({required this.member});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          _MemberHero(member: member),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _InfoCard(member: member),
                const SizedBox(height: 16),
                _FamilyCard(member: member),
                const SizedBox(height: 16),
                MemberPaymentsSection(member: member),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberHero extends StatelessWidget {
  final Member member;
  const _MemberHero({required this.member});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.primary,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_rounded, color: Colors.white),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddEditMemberScreen(member: member)),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 56),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accentLight, width: 2),
                ),
                child: Center(
                  child: Text(member.initials, style: GoogleFonts.amiri(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
              Text(member.name, style: GoogleFonts.amiri(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              Text(member.housePlace, style: GoogleFonts.notoSans(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Member member;
  const _InfoCard({required this.member});

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Member Information',
      icon: Icons.person_rounded,
      child: Column(
        children: [
          _Row('Member ID', member.id, Icons.badge_rounded),
          if (member.nameMl.trim().isNotEmpty)
            _Row('Name (Malayalam)', member.nameMl, Icons.translate_rounded),
          if (member.fatherName.isNotEmpty)
            _Row('Father', member.fatherName, Icons.person_outline_rounded),
          _Row('Phone', member.phone, Icons.phone_rounded),
          _Row('Place / Area', member.housePlace, Icons.location_on_rounded),
          _Row('Serial No.', member.houseNumber, Icons.home_rounded),
          if (member.address.isNotEmpty) _Row('Address', member.address, Icons.map_rounded),
          if (member.age != null) _Row('Age', '${member.age} years', Icons.cake_rounded),
          if (member.occupation != null) _Row('Occupation', member.occupation!, Icons.work_rounded),
          if (member.email != null) _Row('Email', member.email!, Icons.email_rounded),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _FamilyCard extends StatelessWidget {
  final Member member;
  const _FamilyCard({required this.member});

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Family Members (${member.familyMembers.length})',
      icon: Icons.family_restroom_rounded,
      child: member.familyMembers.isEmpty
          ? Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text('No family members added.', style: Theme.of(context).textTheme.bodyMedium),
      )
          : Column(
        children: member.familyMembers
            .map((f) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryLighter.withOpacity(0.15),
            child: Text(
              f.name.isNotEmpty ? f.name[0] : '?',
              style: GoogleFonts.amiri(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          title: Text(f.name, style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text('${f.relation}${f.age != null ? " • ${f.age} yrs" : ""}', style: Theme.of(context).textTheme.bodySmall),
          trailing: f.occupation != null ? Text(f.occupation!, style: Theme.of(context).textTheme.bodySmall) : null,
          dense: true,
        ))
            .toList(),
      ),
    );
  }
}


// ─── Shared Widgets ─────────────────────────────────────────────
class _Card extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? action;
  const _Card({required this.title, required this.icon, required this.child, this.action});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.06), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                if (action != null) ...[const Spacer(), action!],
              ],
            ),
          ),
          const Divider(height: 16),
          Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: child),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _Row(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AppColors.textLight),
          const SizedBox(width: 8),
          SizedBox(width: 110, child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary))),
        ],
      ),
    );
  }
}