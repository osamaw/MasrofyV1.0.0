import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:masroofy/screens/login_screen.dart';
import 'package:masroofy/screens/signup_screen.dart';
import 'package:masroofy/utils/session_manager.dart';
import 'models/user.dart';
import 'models/expense.dart';
import 'models/bill.dart';
import 'models/installment.dart';
import 'models/income.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(BillAdapter());
  Hive.registerAdapter(InstallmentAdapter());
  Hive.registerAdapter(IncomeAdapter());

  await Hive.openBox<User>('users');
  await Hive.openBox<Expense>('expenses');
  await Hive.openBox<Bill>('bills');
  await Hive.openBox<Installment>('installments');
  await Hive.openBox<Income>('income');
  bool isLoggedIn = false;
  
  String? savedEmail = await SessionManager().getCachedEmail();

  if (savedEmail != null) {
    var userBox = Hive.box<User>('users');
    
    try {
      User savedUser = userBox.values.firstWhere((u) => u.Email == savedEmail);
      
      SessionManager().currentUser = savedUser; 
      
      isLoggedIn = true;
    } catch (e) {
      isLoggedIn = false; 
    }
  }

  var userBox = Hive.box<User>('users');
  runApp(MasroofyApp(isLoggedIn: isLoggedIn));
}

class MasroofyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MasroofyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Masroofy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
