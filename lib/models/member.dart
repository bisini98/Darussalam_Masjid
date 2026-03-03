class FamilyMember {
  final String id;
  final String name;
  final String relation;
  final int? age;
  final String? phone;
  final String? occupation;

  FamilyMember({
    required this.id,
    required this.name,
    required this.relation,
    this.age,
    this.phone,
    this.occupation,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) => FamilyMember(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    relation: json['relation'] ?? '',
    age: json['age'],
    phone: json['phone'],
    occupation: json['occupation'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'relation': relation,
    'age': age,
    'phone': phone,
    'occupation': occupation,
  };
}

enum Gender { male, female }

class Member {
  final String id;
  String name;
  String phone;
  String? email;
  String mahalName;
  String housePlace;
  String houseNumber;
  String address;
  Gender gender;
  int? age;
  String? occupation;
  bool isActive;
  List<FamilyMember> familyMembers;
  DateTime joinedDate;
  String? notes;

  Member({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.mahalName,
    required this.housePlace,
    required this.houseNumber,
    required this.address,
    this.gender = Gender.male,
    this.age,
    this.occupation,
    this.isActive = true,
    List<FamilyMember>? familyMembers,
    DateTime? joinedDate,
    this.notes,
  })  : familyMembers = familyMembers ?? [],
        joinedDate = joinedDate ?? DateTime.now();

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}