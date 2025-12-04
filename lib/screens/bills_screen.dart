import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/bill.dart';
import '../utils/session_manager.dart';
import 'add_bill_screen.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  late Box<Bill> billBox;

  @override
  void initState() {
    super.initState();
    billBox = Hive.box<Bill>('bills');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bills')),
      body: ValueListenableBuilder(
        valueListenable: billBox.listenable(),
        builder: (context, Box<Bill> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('No bills yet.'));
          }

          final currentUserEmail = SessionManager().currentUser?.Email;
          final bills = box.values
              .where((b) => b.userEmail == currentUserEmail)
              .toList();

          return ListView.builder(
            itemCount: bills.length,
            itemBuilder: (context, index) {
              final bill = bills[index];
              return ListTile(
                leading: const Icon(Icons.receipt),
                title: Text(bill.name),
                subtitle: Text(
                  '${DateFormat.yMMMd().format(bill.date)} ${bill.isRecurring ? "(Recurring)" : ""}',
                ),
                trailing: Text(
                  '\$${bill.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onLongPress: () {
                  bill.delete();
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
            MaterialPageRoute(builder: (context) => const AddBillScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
