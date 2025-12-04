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
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Masroofy Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
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
                              Colors.green,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSummaryCard(
                                    'Monthly Expenses',
                                    totalExpenses,
                                    Colors.redAccent,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildSummaryCard(
                                    'Bills + Installments',
                                    totalBillsAndInstallments,
                                    Colors.orange,
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
}
