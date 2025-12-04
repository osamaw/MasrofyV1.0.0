import 'package:hive/hive.dart';

part 'installment.g.dart';

@HiveType(typeId: 2)
class Installment extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final double totalPrice;

  @HiveField(2)
  final int totalMonths;

  @HiveField(3)
  final DateTime startDate;

  @HiveField(4)
  final double monthlyAmount;

  @HiveField(5)
  final String userEmail;

  Installment({
    required this.name,
    required this.totalPrice,
    required this.totalMonths,
    required this.startDate,
    required this.monthlyAmount,
    required this.userEmail,
  });
}
