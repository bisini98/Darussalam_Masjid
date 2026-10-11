import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ledger.dart';
import 'package:flutter/foundation.dart';
import '../models/member.dart';
import '../models/sadaqah.dart';

class AppProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  // ---- Members ----

  final List<Member> _members = [];
  String _searchQuery = '';
  String _selectedPlace = 'All';

  List<Member> get members => _members;

  List<Member> get filteredMembers {
    var list = _members.where((m) => m.isActive).toList();
    if (_selectedPlace != 'All') {
      list = list.where((m) => m.housePlace == _selectedPlace).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      final exact = list.where((m) => m.id == _searchQuery.trim()).toList();
      if (exact.isNotEmpty) return exact;
      list = list
          .where((m) =>
      m.id == _searchQuery.trim() ||
      m.name.toLowerCase().contains(q) ||
          m.phone.contains(q) ||
          m.houseNumber.toLowerCase().contains(q) ||
          m.housePlace.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  List<String> get allPlaces {
    final places = _members.map((m) => m.housePlace).toSet().toList();
    places.sort();
    return ['All', ...places];
  }

  String get searchQuery => _searchQuery;
  String get selectedPlace => _selectedPlace;

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setSelectedPlace(String place) {
    _selectedPlace = place;
    notifyListeners();
  }

  // ---- Test mode: when ON, nothing is written to Firebase ----
  bool testMode = true;
  void setTestMode(bool v) {
    testMode = v;
    notifyListeners();
  }

  Future<void> _write(Future<void> Function() action) async {
    if (testMode) return;
    await action().timeout(const Duration(seconds: 15));
  }

  String nextMemberId() {
    var max = 0;
    for (final m in _members) {
      final n = int.tryParse(m.id) ?? 0;
      if (n > max && n < 100000) max = n;
    }
    return '${max + 1}';
  }

  Map<String, dynamic> _memberToMap(Member m) => {
    'id': m.id,
    'name': m.name,
    'familyName': '',
    'nameMl': m.nameMl,
    'familyNameMl': '',
    'father': m.fatherName,
    'phone': m.phone,
    'email': m.email,
    'area': m.housePlace,
    'slNo': m.houseNumber,
    'address': m.address,
    'age': m.age,
    'occupation': m.occupation,
    'notes': m.notes,
    'isActive': m.isActive,
    'extras': m.extras,
    'familyMembers': m.familyMembers.map((f) => f.toJson()).toList(),
  };

  Future<void> addMember(Member m) async {
    m.legacyMonths = {...m.legacyMonths};
    m.extras = {...m.extras};
    _members.add(m);
    notifyListeners();
    await _write(() => _db.collection('members').doc(m.id).set(_memberToMap(m)));
  }

  Future<void> updateMember(Member m) async {
    final idx = _members.indexWhere((e) => e.id == m.id);
    if (idx != -1) {
      _members[idx] = m;
      notifyListeners();
    }
    await _write(() => _db
        .collection('members')
        .doc(m.id)
        .set(_memberToMap(m), SetOptions(merge: true)));
  }


  Future<void> deleteMember(String id) async {
    final m = getMember(id);
    if (m == null) return;
    m.isActive = false;
    notifyListeners();
    await _write(() => _db.collection('members').doc(id).update({'isActive': false}));
  }

  Member? getMember(String id) {
    try {
      return _members.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  // ---- Sadaqah Seasons ----
  final List<SadaqahSeason> _seasons = [];
  List<SadaqahSeason> get seasons => _seasons;
  List<SadaqahSeason> get activeSeasons => _seasons.where((s) => s.isActive).toList();

  void addSeason(SadaqahSeason s) {
    _seasons.add(s);
    notifyListeners();
  }

  void updateSeason(SadaqahSeason s) {
    final idx = _seasons.indexWhere((e) => e.id == s.id);
    if (idx != -1) {
      _seasons[idx] = s;
      notifyListeners();
    }
  }

  SadaqahSeason? getSeason(String id) {
    try {
      return _seasons.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  // ---- Payments ----
  final List<SadaqahPayment> _payments = [];
  List<SadaqahPayment> get payments => _payments;

  List<SadaqahPayment> getPaymentsByMember(String memberId) =>
      _payments.where((p) => p.memberId == memberId).toList();

  List<SadaqahPayment> getPaymentsBySeason(String seasonId) =>
      _payments.where((p) => p.seasonId == seasonId).toList();

  void addPayment(SadaqahPayment p) {
    _payments.add(p);
    notifyListeners();
  }

  void updatePayment(SadaqahPayment p) {
    final idx = _payments.indexWhere((e) => e.id == p.id);
    if (idx != -1) {
      _payments[idx] = p;
      notifyListeners();
    }
  }

  double getTotalCollectedForSeason(String seasonId) {
    return _payments
        .where((p) => p.seasonId == seasonId)
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  bool hasMemberPaidForSeason(String memberId, String seasonId) {
    return _payments.any((p) => p.memberId == memberId && p.seasonId == seasonId);
  }

  // ---- Dashboard Stats ----
  int get totalMembers => _members.where((m) => m.isActive).length;
  int get totalFamilyMembers =>
      _members.fold(0, (sum, m) => sum + m.familyMembers.length);
  double get totalCollectedAllTime =>
      _payments.fold(0.0, (sum, p) => sum + p.amount);
  int get totalSeasons => _seasons.length;

  // ---- Seed Data ----

  // ---- Firebase: categories, payments, loading ----
  final List<PayCategory> _categories = [];
  final List<Payment> _ledger = [];
  List<PayCategory> get categories => _categories;

  List<Payment> paymentsOf(String memberId) =>
      _ledger.where((p) => p.memberId == memberId).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  Member _memberFromMap(Map<String, dynamic> j) {
    String join(String a, String b, {bool bracket = false}) {
      a = a.trim();
      b = b.trim();
      if (b.isEmpty) return a;
      return bracket ? '$a ($b)' : '$a $b';
    }

    return Member(
      id: '${j['id']}',
      name: join('${j['name'] ?? ''}', '${j['familyName'] ?? ''}', bracket: true),
      nameMl: join('${j['nameMl'] ?? ''}', '${j['familyNameMl'] ?? ''}'),
      fatherName: j['father'] ?? '',
      phone: j['phone'] ?? '',
      email: j['email'],
      mahalName: 'Darulsalam Masjid',
      housePlace: j['area'] ?? '',
      houseNumber: '${j['slNo'] ?? ''}',
      address: j['address'] ?? '',
      age: j['age'],
      occupation: j['occupation'],
      notes: j['notes'],
      isActive: j['isActive'] ?? true,
      familyMembers: ((j['familyMembers'] ?? []) as List)
          .map((f) => FamilyMember.fromJson(Map<String, dynamic>.from(f)))
          .toList(),
      extras: Map<String, dynamic>.from(j['extras'] ?? {}),
      legacyMonths: Map<String, num>.from(j['legacyMonths'] ?? {}),
    );
  }

  Future<void> loadFromFirestore() async {
    final cats = await _db.collection('categories').get();
    _categories
      ..clear()
      ..addAll(cats.docs.map((d) => PayCategory.fromJson(d.data())));
    final ms = await _db.collection('members').get();
    _members
      ..clear()
      ..addAll(ms.docs.map((d) => _memberFromMap(d.data())));
    notifyListeners();
  }

  Future<void> loadPaymentsFor(String memberId) async {
    final q = await _db
        .collection('payments')
        .where('memberId', isEqualTo: memberId)
        .get();
    _ledger.removeWhere((p) => p.memberId == memberId);
    _ledger.addAll(q.docs.map((d) => Payment.fromJson(d.data())));
    notifyListeners();
  }

  String addCategory(String name) {
    final id = name.toLowerCase().trim().replaceAll(RegExp(r'\s+'), '_');
    if (_categories.any((c) => c.id == id)) return id;
    _categories.add(PayCategory(id: id, name: name.trim()));
    notifyListeners();
    _write(() => _db
        .collection('categories')
        .doc(id)
        .set({'id': id, 'name': name.trim(), 'builtIn': false}));
    return id;
  }

  /// Marks months as paid on the member (single source for the month grid).
  Future<void> _setMonths(String memberId, List<String> months, double perMonth) async {
    final m = getMember(memberId);
    if (m == null || months.isEmpty) return;
    for (final ym in months) {
      m.legacyMonths[ym] = perMonth;
    }
    notifyListeners();
    await _write(() => _db.collection('members').doc(memberId).update({
      for (final ym in months) FieldPath(['legacyMonths', ym]): perMonth,
    }));
  }

  Future<void> _clearMonths(String memberId, List<String> months) async {
    final m = getMember(memberId);
    if (m == null || months.isEmpty) return;
    for (final ym in months) {
      m.legacyMonths.remove(ym);
    }
    notifyListeners();
    await _write(() => _db.collection('members').doc(memberId).update({
      for (final ym in months) FieldPath(['legacyMonths', ym]): FieldValue.delete(),
    }));
  }

  Future<void> addLedgerPayment(Payment p) async {
    _ledger.add(p);
    notifyListeners();
    await _write(() => _db.collection('payments').doc(p.id).set(p.toJson()));
    if (p.categoryId == 'subscription') {
      await _setMonths(p.memberId, p.months, p.amount / (p.months.isEmpty ? 1 : p.months.length));
    }
  }

  Future<void> updateLedgerPayment(Payment p) async {
    final i = _ledger.indexWhere((e) => e.id == p.id);
    if (i == -1) return;
    final old = _ledger[i];
    _ledger[i] = p;
    notifyListeners();
    await _write(() => _db.collection('payments').doc(p.id).set(p.toJson()));
    if (old.categoryId == 'subscription') await _clearMonths(old.memberId, old.months);
    if (p.categoryId == 'subscription') {
      await _setMonths(p.memberId, p.months, p.amount / (p.months.isEmpty ? 1 : p.months.length));
    }
  }

  Future<void> deleteLedgerPayment(Payment p) async {
    _ledger.removeWhere((e) => e.id == p.id);
    notifyListeners();
    await _write(() => _db.collection('payments').doc(p.id).delete());
    if (p.categoryId == 'subscription') await _clearMonths(p.memberId, p.months);
  }

  /// Usual monthly amount for this member (latest paid month), default 100.
  double monthlyRate(String memberId) {
    final m = getMember(memberId);
    if (m == null) return 100;
    final keys = m.legacyMonths.keys.toList()..sort();
    for (final k in keys.reversed) {
      final v = m.legacyMonths[k] ?? 0;
      if (v > 0) return v.toDouble();
    }
    return 100;
  }

  /// Months from Jan 2026 up to this month that are not paid.
  List<String> dueMonths(String memberId, {String from = '2026-01'}) {
    final paid = paidMonths(memberId);
    final now = DateTime.now();
    final out = <String>[];
    var y = int.parse(from.substring(0, 4));
    var mo = int.parse(from.substring(5));
    while (y < now.year || (y == now.year && mo <= now.month)) {
      final key = '$y-${mo.toString().padLeft(2, '0')}';
      if (!paid.contains(key)) out.add(key);
      if (++mo > 12) {
        mo = 1;
        y++;
      }
    }
    return out;
  }

  /// Months already paid: old Excel grid + payments entered in the app.
  Set<String> paidMonths(String memberId) {
    final m = getMember(memberId);
    final s = <String>{...?m?.legacyMonths.keys};
    for (final p in _ledger.where(
            (p) => p.memberId == memberId && p.categoryId == 'subscription')) {
      s.addAll(p.months);
    }
    return s;
  }

  /// "He gave 500" -> which months does it cover (suggestion only).
  List<String> suggestMonths(String memberId, double amount,
      {double rate = 100, String from = '2026-01'}) {
    final paid = paidMonths(memberId);
    final out = <String>[];
    var y = int.parse(from.substring(0, 4));
    var mo = int.parse(from.substring(5));
    var left = amount;
    while (left >= rate && y < 2030) {
      final key = '$y-${mo.toString().padLeft(2, '0')}';
      if (!paid.contains(key)) {
        out.add(key);
        left -= rate;
      }
      if (++mo > 12) {
        mo = 1;
        y++;
      }
    }
    return out;
  }

  void seedSampleData() {
    // Sample places
    final places = ['Palat', 'Thazhe', 'Vadakke', 'Kizhakke', 'Padi'];
    final occupations = ['Farmer', 'Teacher', 'Business', 'Engineer', 'Driver', 'Doctor'];

    int memberCount = 0;
    for (final place in places) {
      for (int i = 1; i <= 6; i++) {
        memberCount++;
        final family = <FamilyMember>[];
        for (int j = 1; j <= (i % 3) + 1; j++) {
          family.add(FamilyMember(
            id: 'fm-$memberCount-$j',
            name: ['Ahmed Ali', 'Fatima', 'Ibrahim', 'Khadija', 'Yusuf', 'Maryam'][j % 6],
            relation: ['Son', 'Daughter', 'Wife', 'Father'][j % 4],
            age: 15 + j * 5,
          ));
        }
        _members.add(Member(
          id: 'member-$memberCount',
          name: [
            'Abdul Rahman',
            'Mohammed Shafi',
            'Siddique P',
            'Hamza K',
            'Umar Farooq',
            'Ali Hassan'
          ][i % 6] +
              ' ${place[0]}',
          phone: '9${800000000 + memberCount}',
          mahalName: 'Mujahid Masjid',
          housePlace: place,
          houseNumber: 'H-${place[0]}${i.toString().padLeft(2, '0')}',
          address: '$place Ward, Mahal Area',
          age: 30 + i * 3,
          occupation: occupations[i % 6],
          familyMembers: family,
          isActive: true,
        ));
      }
    }

    // Sample seasons
    final season1 = SadaqahSeason(
      id: 'season-1',
      name: 'Ramadan 1446',
      description: 'Ramadan Sadaqah Collection 2025',
      startDate: DateTime(2025, 3, 1),
      endDate: DateTime(2025, 4, 1),
      targetAmount: 50000,
      isActive: false,
      category: 'Zakat Fitrah',
    );
    final season2 = SadaqahSeason(
      id: 'season-2',
      name: 'Muharram 1447',
      description: 'Annual Masjid Maintenance Fund',
      startDate: DateTime(2025, 7, 1),
      targetAmount: 75000,
      isActive: true,
      category: 'General Sadaqah',
    );
    _seasons.addAll([season1, season2]);

    // Sample payments
    int receiptNum = 1000;
    for (int i = 0; i < _members.length; i++) {
      final m = _members[i];
      if (i % 2 == 0) {
        _payments.add(SadaqahPayment(
          id: 'payment-s1-$i',
          memberId: m.id,
          memberName: m.name,
          seasonId: 'season-1',
          seasonName: 'Ramadan 1446',
          amount: [500, 1000, 250, 750, 2000][i % 5].toDouble(),
          paymentDate: DateTime(2025, 3, 10 + i % 20),
          receiptNumber: 'MAS/${receiptNum++}',
        ));
      }
      if (i % 3 == 0) {
        _payments.add(SadaqahPayment(
          id: 'payment-s2-$i',
          memberId: m.id,
          memberName: m.name,
          seasonId: 'season-2',
          seasonName: 'Muharram 1447',
          amount: [1000, 500, 1500, 2000][i % 4].toDouble(),
          paymentDate: DateTime(2025, 7, 5 + i % 25),
          receiptNumber: 'MAS/${receiptNum++}',
        ));
      }
    }

    notifyListeners();
  }
}