class SadaqahSeason {
  final String id;
  String name; // e.g., "Ramadan 2024", "Muharram 1446"
  String description;
  DateTime startDate;
  DateTime? endDate;
  double targetAmount;
  bool isActive;
  String category; // Zakat, Fitr, General Sadaqah, etc.

  SadaqahSeason({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    this.endDate,
    this.targetAmount = 0,
    this.isActive = true,
    this.category = 'General Sadaqah',
  });

  double get totalCollected => 0; // Computed from payments
}

enum PaymentStatus { paid, partial, pending }

class SadaqahPayment {
  final String id;
  final String memberId;
  final String memberName;
  final String seasonId;
  final String seasonName;
  double amount;
  PaymentStatus status;
  DateTime paymentDate;
  String? notes;
  String receiptNumber;
  String adminNote;

  SadaqahPayment({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.seasonId,
    required this.seasonName,
    required this.amount,
    this.status = PaymentStatus.paid,
    DateTime? paymentDate,
    this.notes,
    required this.receiptNumber,
    this.adminNote = '',
  }) : paymentDate = paymentDate ?? DateTime.now();

  String get formattedAmount => '₹${amount.toStringAsFixed(2)}';
  String get formattedDate {
    return '${paymentDate.day.toString().padLeft(2, '0')}/'
        '${paymentDate.month.toString().padLeft(2, '0')}/'
        '${paymentDate.year}';
  }
}