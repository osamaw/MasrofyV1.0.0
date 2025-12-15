import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../utils/session_manager.dart';
import 'add_expense_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  late Box<Expense> expenseBox;

  @override
  void initState() {
    super.initState();
    expenseBox = Hive.box<Expense>('expenses');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: ValueListenableBuilder(
        valueListenable: expenseBox.listenable(),
        builder: (context, Box<Expense> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('No expenses yet.'));
          }

          final currentUserEmail = SessionManager().currentUser?.Email;
          final expenses =
              box.values.where((e) => e.userEmail == currentUserEmail).toList()
                ..sort((a, b) => b.date.compareTo(a.date));

          return ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(expense.category[0].toUpperCase()),
                ),
                title: Text(expense.name),
                subtitle: Text(DateFormat.yMMMd().format(expense.date)),
                trailing: Text(
                  '\$${expense.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onLongPress: () {
                 showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Delete"),
                    content: Text("Are You Sure ?"),
                    actions: [
                      ElevatedButton(onPressed:  () {
                              expense.delete();
                              Navigator.of(context).pop();
                            }, child: Text("Yes")),
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
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
