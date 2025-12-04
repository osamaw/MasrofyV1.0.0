import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/installment.dart';
import '../utils/session_manager.dart';
import 'add_installment_screen.dart';

class InstallmentsScreen extends StatefulWidget {
  const InstallmentsScreen({super.key});

  @override
  State<InstallmentsScreen> createState() => _InstallmentsScreenState();
}

class _InstallmentsScreenState extends State<InstallmentsScreen> {
  late Box<Installment> installmentBox;

  @override
  void initState() {
    super.initState();
    installmentBox = Hive.box<Installment>('installments');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Installments')),
      body: ValueListenableBuilder(
        valueListenable: installmentBox.listenable(),
        builder: (context, Box<Installment> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('No installments yet.'));
          }

          final currentUserEmail = SessionManager().currentUser?.Email;
          final installments = box.values
              .where((i) => i.userEmail == currentUserEmail)
              .toList();

          return ListView.builder(
            itemCount: installments.length,
            itemBuilder: (context, index) {
              final installment = installments[index];

              return ListTile(
                leading: const Icon(Icons.credit_card),
                title: Text(installment.name),
                subtitle: Text(
                  '${installment.totalMonths} months starting ${DateFormat.yMMMd().format(installment.startDate)}',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${installment.monthlyAmount.toStringAsFixed(2)}/mo',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Total: \$${installment.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                onLongPress: () {
                  installment.delete();
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
            MaterialPageRoute(
              builder: (context) => const AddInstallmentScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
