import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/member.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import 'add_edit_member_screen.dart';
import 'members_detail_screen.dart';

class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Mahal Members'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddEditMemberScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _SearchAndFilter(),
          Expanded(child: _MemberList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditMemberScreen()),
        ),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: Text('Add Member', style: GoogleFonts.notoSans(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _SearchAndFilter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, p, _) {
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            children: [
              // Search
              TextField(
                onChanged: p.setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Search by member ID, name or phone...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textLight),
                  suffixIcon: p.searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () => p.setSearchQuery(''),
                  )
                      : null,
                ),
              ),
              const SizedBox(height: 10),
              // Place filter chips
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: p.allPlaces.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final place = p.allPlaces[i];
                    final selected = p.selectedPlace == place;
                    return FilterChip(
                      label: Text(place, style: GoogleFonts.notoSans(fontSize: 12, fontWeight: selected ? FontWeight.w600 : FontWeight.normal, color: selected ? Colors.white : AppColors.textPrimary)),
                      selected: selected,
                      onSelected: (_) => p.setSelectedPlace(place),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surfaceDark,
                      checkmarkColor: Colors.white,
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _MemberList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, p, _) {
        final members = p.filteredMembers;
        if (members.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline_rounded, size: 64, color: AppColors.textLight),
                const SizedBox(height: 12),
                Text('No members found', style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: members.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) => _MemberCard(member: members[i]),
        );
      },
    );
  }
}

class _MemberCard extends StatelessWidget {
  final Member member;
  const _MemberCard({required this.member});

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<AppProvider>(context, listen: false);
    final dues = p.dueMonths(member.id).length;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MemberDetailScreen(memberId: member.id)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(member.initials, style: GoogleFonts.amiri(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('#${member.id}  ${member.name}', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 13, color: AppColors.textLight),
                      const SizedBox(width: 3),
                      Text(member.housePlace, style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(width: 8),
                      const Icon(Icons.home_rounded, size: 13, color: AppColors.textLight),
                      const SizedBox(width: 3),
                      Text(member.houseNumber, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.phone_rounded, size: 13, color: AppColors.textLight),
                      const SizedBox(width: 3),
                      Text(member.phone, style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(width: 8),
                      const Icon(Icons.family_restroom_rounded, size: 13, color: AppColors.textLight),
                      const SizedBox(width: 3),
                      Text('${member.familyMembers.length} family', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
            // Payment badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (dues == 0 ? AppColors.success : AppColors.warning).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    dues == 0 ? 'Up to date' : '$dues months due',
                    style: GoogleFonts.notoSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: dues == 0 ? AppColors.success : AppColors.warning,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
              ],
            ),
          ],
        ),
      ),
    );
  }
}