import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/member.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';

class AddEditMemberScreen extends StatefulWidget {
  final Member? member;
  const AddEditMemberScreen({super.key, this.member});

  @override
  State<AddEditMemberScreen> createState() => _AddEditMemberScreenState();
}

class _AddEditMemberScreenState extends State<AddEditMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name = TextEditingController(text: widget.member?.name ?? '');
  late final TextEditingController _phone = TextEditingController(text: widget.member?.phone ?? '');
  late final TextEditingController _email = TextEditingController(text: widget.member?.email ?? '');
  late final TextEditingController _houseNumber = TextEditingController(text: widget.member?.houseNumber ?? '');
  late final TextEditingController _address = TextEditingController(text: widget.member?.address ?? '');
  late final TextEditingController _occupation = TextEditingController(text: widget.member?.occupation ?? '');
  late final TextEditingController _housePlace = TextEditingController(text: widget.member?.housePlace ?? '');
  late int? _age = widget.member?.age;
  late Gender _gender = widget.member?.gender ?? Gender.male;
  late List<FamilyMember> _family = List.from(widget.member?.familyMembers ?? []);

  bool get isEdit => widget.member != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Member' : 'Add New Member'),
        backgroundColor: AppColors.primary,
        actions: [
          TextButton(
            onPressed: _save,
            child: Text('Save', style: GoogleFonts.notoSans(color: AppColors.accentLight, fontWeight: FontWeight.w600, fontSize: 15)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _section('Personal Information'),
              _card(Column(
                children: [
                  _field(_name, 'Full Name', Icons.person_rounded, required: true),
                  const SizedBox(height: 12),
                  _field(_phone, 'Phone Number', Icons.phone_rounded, keyboardType: TextInputType.phone, required: true),
                  const SizedBox(height: 12),
                  _field(_email, 'Email Address', Icons.email_rounded, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 12),
                  _field(_occupation, 'Occupation', Icons.work_rounded),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: _age?.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _age = int.tryParse(v),
                    decoration: _deco('Age', Icons.cake_rounded),
                  ),
                  const SizedBox(height: 12),
                  // Gender
                  Row(
                    children: [
                      Text('Gender:', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(width: 16),
                      ...Gender.values.map((g) => Row(
                        children: [
                          Radio<Gender>(value: g, groupValue: _gender, onChanged: (v) => setState(() => _gender = v!), activeColor: AppColors.primary),
                          Text(g.name.capitalize(), style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(width: 8),
                        ],
                      )),
                    ],
                  ),
                ],
              )),
              const SizedBox(height: 16),
              _section('House Information'),
              _card(Column(
                children: [
                  _field(_houseNumber, 'House Number', Icons.home_rounded, required: true),
                  const SizedBox(height: 12),
                  _field(_housePlace, 'Place / Area (for filtering)', Icons.location_on_rounded, required: true),
                  const SizedBox(height: 12),
                  _field(_address, 'Full Address', Icons.map_rounded, maxLines: 2),
                ],
              )),
              const SizedBox(height: 16),
              _section('Family Members'),
              _card(_FamilyEditor(
                family: _family,
                onChanged: (f) => setState(() => _family = f),
              )),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(isEdit ? 'Update Member' : 'Add Member'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
  );

  Widget _card(Widget child) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.06), blurRadius: 10)],
    ),
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(bottom: 4),
    child: child,
  );

  Widget _field(
      TextEditingController ctrl,
      String hint,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
        bool required = false,
        int maxLines = 1,
      }) =>
      TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: required ? (v) => (v == null || v.isEmpty) ? 'Required' : null : null,
        decoration: _deco(hint, icon),
      );

  InputDecoration _deco(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, size: 18, color: AppColors.textLight),
  );

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final p = Provider.of<AppProvider>(context, listen: false);
    if (isEdit) {
      widget.member!
        ..name = _name.text
        ..phone = _phone.text
        ..email = _email.text.isEmpty ? null : _email.text
        ..houseNumber = _houseNumber.text
        ..housePlace = _housePlace.text
        ..address = _address.text
        ..occupation = _occupation.text.isEmpty ? null : _occupation.text
        ..age = _age
        ..gender = _gender
        ..familyMembers.clear()
        ..familyMembers.addAll(_family);
      p.updateMember(widget.member!);
    } else {
      p.addMember(Member(
        id: p.nextMemberId(),
        name: _name.text,
        phone: _phone.text,
        email: _email.text.isEmpty ? null : _email.text,
        houseNumber: _houseNumber.text,
        housePlace: _housePlace.text,
        address: _address.text,
        occupation: _occupation.text.isEmpty ? null : _occupation.text,
        mahalName: 'Mujahid Masjid',
        age: _age,
        gender: _gender,
        familyMembers: _family,
      ));
    }
    Navigator.pop(context);
  }
}

class _FamilyEditor extends StatefulWidget {
  final List<FamilyMember> family;
  final ValueChanged<List<FamilyMember>> onChanged;
  const _FamilyEditor({required this.family, required this.onChanged});

  @override
  State<_FamilyEditor> createState() => _FamilyEditorState();
}

class _FamilyEditorState extends State<_FamilyEditor> {
  late List<FamilyMember> _list;

  @override
  void initState() {
    super.initState();
    _list = List.from(widget.family);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ..._list.asMap().entries.map((e) => _FamilyTile(
          member: e.value,
          onDelete: () {
            _list.removeAt(e.key);
            widget.onChanged(_list);
            setState(() {});
          },
        )),
        TextButton.icon(
          onPressed: _add,
          icon: const Icon(Icons.add_rounded, color: AppColors.primary),
          label: Text('Add Family Member', style: GoogleFonts.notoSans(color: AppColors.primary, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  void _add() async {
    final result = await showDialog<FamilyMember>(
      context: context,
      builder: (_) => _AddFamilyDialog(),
    );
    if (result != null) {
      _list.add(result);
      widget.onChanged(_list);
      setState(() {});
    }
  }
}

class _FamilyTile extends StatelessWidget {
  final FamilyMember member;
  final VoidCallback onDelete;
  const _FamilyTile({required this.member, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: Text(member.name[0], style: GoogleFonts.amiri(color: AppColors.primary, fontWeight: FontWeight.bold)),
      ),
      title:Text('#${member.id}  ${member.name}', style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text('${member.relation}${member.age != null ? " • ${member.age} yrs" : ""}'),
      trailing: IconButton(icon: const Icon(Icons.delete_rounded, color: AppColors.error, size: 18), onPressed: onDelete),
      dense: true,
    );
  }
}

class _AddFamilyDialog extends StatefulWidget {
  @override
  State<_AddFamilyDialog> createState() => _AddFamilyDialogState();
}

class _AddFamilyDialogState extends State<_AddFamilyDialog> {
  final _name = TextEditingController();
  String _relation = 'Son';
  int? _age;
  final _relations = ['Son', 'Daughter', 'Wife', 'Father', 'Mother', 'Brother', 'Sister', 'Other'];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Add Family Member', style: GoogleFonts.amiri(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _name, decoration: const InputDecoration(hintText: 'Full Name', prefixIcon: Icon(Icons.person_rounded))),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _relation,
            items: _relations.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: (v) => setState(() => _relation = v!),
            decoration: const InputDecoration(prefixIcon: Icon(Icons.people_rounded)),
          ),
          const SizedBox(height: 12),
          TextField(
            keyboardType: TextInputType.number,
            onChanged: (v) => _age = int.tryParse(v),
            decoration: const InputDecoration(hintText: 'Age (optional)', prefixIcon: Icon(Icons.cake_rounded)),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_name.text.isEmpty) return;
            Navigator.pop(
              context,
              FamilyMember(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: _name.text,
                relation: _relation,
                age: _age,
              ),
            );
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

extension StringExt on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}