import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/bill.dart';
import '../utils/session_manager.dart';

class AddBillScreen extends StatefulWidget {
  const AddBillScreen({super.key});

  @override
  State<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;
  bool _hasReminder = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Bill')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a name'
                    : null,
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || double.tryParse(value) == null
                    ? 'Please enter a valid amount'
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Date: ${DateFormat.yMMMd().format(_selectedDate)}'),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              SwitchListTile(
                title: const Text('Is Recurring?'),
                value: _isRecurring,
                onChanged: (val) {
                  setState(() {
                    _isRecurring = val;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Set Reminder?'),
                value: _hasReminder,
                onChanged: (val) {
                  setState(() {
                    _hasReminder = val;
                  });
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveBill,
                child: const Text('Save Bill'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveBill() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final amount = double.parse(_amountController.text);

      final bill = Bill(
        name: name,
        amount: amount,
        date: _selectedDate,
        isRecurring: _isRecurring,
        hasReminder: _hasReminder,
        userEmail: SessionManager().currentUser!.Email,
      );

      Hive.box<Bill>('bills').add(bill);
      Navigator.pop(context);
    }
  }
}
