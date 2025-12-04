import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/income.dart';
import '../utils/session_manager.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  late Box<Income> incomeBox;
  final _formKey = GlobalKey<FormState>();
  final _sourceController = TextEditingController();
  final _amountController = TextEditingController();
  String _type = 'Salary';

  @override
  void initState() {
    super.initState();
    incomeBox = Hive.box<Income>('income');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Income')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _sourceController,
                    decoration: const InputDecoration(labelText: 'Source Name'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value == null || double.tryParse(value) == null
                        ? 'Invalid amount'
                        : null,
                  ),
                  DropdownButtonFormField<String>(
                    value: _type,
                    items: ['Salary', 'Extra'].map((t) {
                      return DropdownMenuItem(value: t, child: Text(t));
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _type = val!;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Type'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addIncome,
                    child: const Text('Add Income'),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: incomeBox.listenable(),
              builder: (context, Box<Income> box, _) {
                if (box.isEmpty) {
                  return const Center(child: Text('No income sources added.'));
                }

                final currentUserEmail = SessionManager().currentUser?.Email;
                final incomes = box.values
                    .where((i) => i.userEmail == currentUserEmail)
                    .toList();

                return ListView.builder(
                  itemCount: incomes.length,
                  itemBuilder: (context, index) {
                    final income = incomes[index];
                    return ListTile(
                      leading: Icon(
                        income.type == 'Salary'
                            ? Icons.work
                            : Icons.monetization_on,
                        color: Colors.green,
                      ),
                      title: Text(income.sourceName),
                      subtitle: Text(income.type),
                      trailing: Text(
                        '\$${income.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                      onLongPress: () {
                        income.delete();
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addIncome() {
    if (_formKey.currentState!.validate()) {
      final source = _sourceController.text;
      final amount = double.parse(_amountController.text);

      final income = Income(
        sourceName: source,
        amount: amount,
        type: _type,
        userEmail: SessionManager().currentUser!.Email,
      );

      incomeBox.add(income);

      _sourceController.clear();
      _amountController.clear();
      FocusScope.of(context).unfocus();
    }
  }
}
