import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';
import '../models/bill.dart';
import '../models/installment.dart';
import '../models/income.dart';
import '../utils/session_manager.dart';
import 'login_screen.dart';
import 'expenses_screen.dart';
import 'bills_screen.dart';
import 'installments_screen.dart';
import 'income_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<Expense> expenseBox;
  late Box<Bill> billBox;
  late Box<Installment> installmentBox;
  late Box<Income> incomeBox;

  @override
  void initState() {
    super.initState();
    expenseBox = Hive.box<Expense>('expenses');
    billBox = Hive.box<Bill>('bills');
    installmentBox = Hive.box<Installment>('installments');
    incomeBox = Hive.box<Income>('income');
  }

  String? get currentUserEmail => SessionManager().currentUser?.Email;
  String? get currentUserName => SessionManager().currentUser?.UserName;
  double get totalExpenses {
    final now = DateTime.now();
    return expenseBox.values
        .where(
          (e) =>
              e.userEmail == currentUserEmail &&
              e.date.month == now.month &&
              e.date.year == now.year,
        )
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get totalIncome {
    return incomeBox.values
        .where((e) => e.userEmail == currentUserEmail)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get totalBillsAndInstallments {
    final bills = billBox.values
        .where((b) => b.userEmail == currentUserEmail)
        .fold(0.0, (sum, b) => sum + b.amount);
    final installments = installmentBox.values
        .where((i) => i.userEmail == currentUserEmail)
        .fold(0.0, (sum, i) => sum + i.monthlyAmount);
    return bills + installments;
  }

  double get remainingBalance => totalIncome - totalExpenses;

  void _logout() {
    SessionManager().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Masroofy Dashboard'),
        backgroundColor: Colors.teal,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            SizedBox(height: 50),
            Image.asset("images/logo.png", width: 40),
            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: Text("$currentUserName"),
                subtitle: Text("$currentUserEmail"),
              ),
            ),
            SizedBox(height: 20),

             _DrawerButton("Settings", Icons.settings),
            SizedBox(height: 20),

            _DrawerButton("History", Icons.history),
            SizedBox(height: 20),

            _DrawerButton("About Us", Icons.question_mark),
            SizedBox(height: 20),

            _DrawerButton("Ai Assistant", Icons.assistant),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout,color: Colors.black,),
              label: Text("Log out",style: TextStyle(color: Colors.black),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red
              ),
              
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Log Out"),
                      content: Text("Are You Sure ?"),
                      actions: [
                        ElevatedButton(onPressed: _logout, child: Text("Yes")),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("NO"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: expenseBox.listenable(),
        builder: (context, Box<Expense> box, _) {
          return ValueListenableBuilder(
            valueListenable: incomeBox.listenable(),
            builder: (context, Box<Income> _, __) {
              return ValueListenableBuilder(
                valueListenable: billBox.listenable(),
                builder: (context, Box<Bill> _, __) {
                  return ValueListenableBuilder(
                    valueListenable: installmentBox.listenable(),
                    builder: (context, Box<Installment> _, __) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildSummaryCard(
                              'Remaining Balance',
                              remainingBalance,
                              const Color.fromARGB(255, 22, 81, 24),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSummaryCard(
                                    'Monthly Expenses',
                                    totalExpenses,
                                    const Color.fromARGB(255, 123, 1, 1),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildSummaryCard(
                                    'Bills + Installments',
                                    totalBillsAndInstallments,
                                    const Color.fromARGB(255, 210, 130, 9),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            _buildNavButton(
                              context,
                              'Expenses',
                              Icons.receipt_long,
                              const ExpensesScreen(),
                            ),
                            const SizedBox(height: 16),
                            _buildNavButton(
                              context,
                              'Bills',
                              Icons.calendar_today,
                              const BillsScreen(),
                            ),
                            const SizedBox(height: 16),
                            _buildNavButton(
                              context,
                              'Installments',
                              Icons.credit_card,
                              const InstallmentsScreen(),
                            ),
                            const SizedBox(height: 16),
                            _buildNavButton(
                              context,
                              'Income',
                              Icons.attach_money,
                              const IncomeScreen(),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color) {
    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(
    BuildContext context,
    String title,
    IconData icon,
    Widget screen,
  ) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      icon: Icon(icon),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _DrawerButton(String? title, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon),
      label: Text("$title"),
      style: ElevatedButton.styleFrom(minimumSize: Size(300, 30)),
    );
  }
}
