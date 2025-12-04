import 'package:hive/hive.dart';

part 'bill.g.dart';

@HiveType(typeId: 1)
class Bill extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final bool isRecurring;

  @HiveField(4)
  final bool hasReminder;

  @HiveField(5)
  final String userEmail;

  Bill({
    required this.name,
    required this.amount,
    required this.date,
    required this.isRecurring,
    required this.hasReminder,
    required this.userEmail,
  });
}
