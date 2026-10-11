/// NEW FILE: lib/models/ledger.dart
/// Categories (Subscription, Kit, Meat, Rice, ...) and the payments recorded against them.

class PayCategory {
  final String id;
  String name;
  final bool builtIn; // built-in ones (subscription) cannot be deleted

  PayCategory({required this.id, required this.name, this.builtIn = false});

  factory PayCategory.fromJson(Map<String, dynamic> j) =>
      PayCategory(id: j['id'], name: j['name'], builtIn: j['builtIn'] == true);

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'builtIn': builtIn};
}

class Payment {
  final String id;
  final String memberId;
  String categoryId;
  double amount;
  DateTime date;
  String receiptNo; // book number from the receipt book
  String note;
  /// Months this payment covers, as 'YYYY-MM' (only used for the subscription category).
  List<String> months;
  final String source; // 'excel' = imported, 'app' = entered in the app

  Payment({
    required this.id,
    required this.memberId,
    required this.categoryId,
    required this.amount,
    required this.date,
    this.receiptNo = '',
    this.note = '',
    List<String>? months,
    this.source = 'app',
  }) : months = months ?? [];

  factory Payment.fromJson(Map<String, dynamic> j) => Payment(
        id: j['id'],
        memberId: j['memberId'],
        categoryId: j['categoryId'],
        amount: (j['amount'] as num).toDouble(),
        date: DateTime.parse(j['date']),
        receiptNo: j['receiptNo'] ?? '',
        note: j['note'] ?? '',
        months: List<String>.from(j['months'] ?? const []),
        source: j['source'] ?? 'app',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'memberId': memberId,
        'categoryId': categoryId,
        'amount': amount,
        'date': date.toIso8601String().substring(0, 10),
        'receiptNo': receiptNo,
        'note': note,
        'months': months,
        'source': source,
      };
}
