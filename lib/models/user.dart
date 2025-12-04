import 'package:hive/hive.dart';

part 'user.g.dart';


@HiveType(typeId: 4)
class User extends HiveObject {
  @HiveField(0)
  String UserName;

  @HiveField(1)
  String Email;

  @HiveField(2)
  String Password;

  

  User({
    required this.UserName,
    required this.Email,
    required this.Password,
    
  });
}
