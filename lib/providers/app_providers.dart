import 'package:flutter/foundation.dart';
import '../models/member.dart';
import '../models/sadaqah.dart';

class AppProvider extends ChangeNotifier {
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
      list = list
          .where((m) =>
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

  void addMember(Member m) {
    _members.add(m);
    notifyListeners();
  }

  void updateMember(Member m) {
    final idx = _members.indexWhere((e) => e.id == m.id);
    if (idx != -1) {
      _members[idx] = m;
      notifyListeners();
    }
  }

  void deleteMember(String id) {
    _members.removeWhere((m) => m.id == id);
    notifyListeners();
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