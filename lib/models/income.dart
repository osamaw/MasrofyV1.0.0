import 'package:hive/hive.dart';

part 'income.g.dart';

@HiveType(typeId: 3)
class Income extends HiveObject {
  @HiveField(0)
  final String sourceName;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String type; // 'Salary' or 'Extra'

  @HiveField(3)
  final String userEmail;

  Income({
    required this.sourceName,
    required this.amount,
    required this.type,
    required this.userEmail,
  });
}
