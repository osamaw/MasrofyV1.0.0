import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/installment.dart';
import '../utils/session_manager.dart';

class AddInstallmentScreen extends StatefulWidget {
  const AddInstallmentScreen({super.key});

  @override
  State<AddInstallmentScreen> createState() => _AddInstallmentScreenState();
}

class _AddInstallmentScreenState extends State<AddInstallmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _totalPriceController = TextEditingController();
  final _totalMonthsController = TextEditingController();
  DateTime _startDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Installment')),
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
                controller: _totalPriceController,
                decoration: const InputDecoration(labelText: 'Total Price'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || double.tryParse(value) == null
                    ? 'Please enter a valid price'
                    : null,
              ),
              TextFormField(
                controller: _totalMonthsController,
                decoration: const InputDecoration(labelText: 'Total Months'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || int.tryParse(value) == null
                    ? 'Please enter valid months'
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Start Date: ${DateFormat.yMMMd().format(_startDate)}'),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _startDate = picked;
                        });
                      }
                    },
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveInstallment,
                child: const Text('Save Installment'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveInstallment() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final totalPrice = double.parse(_totalPriceController.text);
      final totalMonths = int.parse(_totalMonthsController.text);

      final monthlyAmount = totalPrice / totalMonths;

      final installment = Installment(
        name: name,
        totalPrice: totalPrice,
        totalMonths: totalMonths,
        startDate: _startDate,
        monthlyAmount: monthlyAmount,
        userEmail: SessionManager().currentUser!.Email,
      );

      Hive.box<Installment>('installments').add(installment);
      Navigator.pop(context);
    }
  }
}
