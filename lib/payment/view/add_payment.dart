// add_payment_screen.dart
import 'package:flutter/material.dart';
import 'package:milvertonrealty/payment/controller/payment_controller.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AddPaymentScreen extends StatefulWidget {
  const AddPaymentScreen({Key? key}) : super(key: key);

  @override
  _AddPaymentScreenState createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _debitOrCreditController = TextEditingController();
  final TextEditingController _paymentMethodController = TextEditingController();
  final TextEditingController _tenantIdController = TextEditingController();
  final TextEditingController _transactionTypeController =
  TextEditingController();
  final TextEditingController _unitIdController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  DateTime? selectedDate;

  @override
  void dispose() {
    _amountController.dispose();
    _debitOrCreditController.dispose();
    _paymentMethodController.dispose();
    _tenantIdController.dispose();
    _transactionTypeController.dispose();
    _unitIdController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime initialDate = selectedDate ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(initialDate.year - 10),
      lastDate: DateTime(initialDate.year + 10),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _submitPayment() {
    if (_formKey.currentState!.validate()) {
      final double amount = double.parse(_amountController.text);
      final String debitOrCredit = _debitOrCreditController.text;
      final String paymentMethod = _paymentMethodController.text;
      final int tenantId = int.parse(_tenantIdController.text);
      final String transactionType = _transactionTypeController.text;
      final int unitId = int.parse(_unitIdController.text);
      final DateTime dateOfTx = selectedDate ?? DateTime.now();

      Provider.of<PaymentProvider>(context, listen: false).addPayment(
        amount: amount,
        dateOfTx: dateOfTx,
        debitOrCredit: debitOrCredit,
        paymentMethod: paymentMethod,
        tenantId: tenantId,
        transactionType: transactionType,
        unitId: unitId,
      );

      Navigator.of(context).pop(); // Return to previous screen.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Payment'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _submitPayment,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Amount Field
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType:
                TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Debit/Credit Field
              TextFormField(
                controller: _debitOrCreditController,
                decoration: InputDecoration(
                  labelText: 'Debit or Credit',
                  hintText: 'debit / credit',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.swap_horiz),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please specify debit or credit';
                  }
                  if (value.toLowerCase() != 'debit' &&
                      value.toLowerCase() != 'credit') {
                    return 'Enter "debit" or "credit"';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Payment Method Field
              TextFormField(
                controller: _paymentMethodController,
                decoration: InputDecoration(
                  labelText: 'Payment Method',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.payment),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter payment method';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Tenant ID Field
              TextFormField(
                controller: _tenantIdController,
                decoration: InputDecoration(
                  labelText: 'Tenant ID',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter tenant ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Transaction Type Field
              TextFormField(
                controller: _transactionTypeController,
                decoration: InputDecoration(
                  labelText: 'Transaction Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter transaction type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Unit ID Field
              TextFormField(
                controller: _unitIdController,
                decoration: InputDecoration(
                  labelText: 'Unit ID',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter unit ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Date Field
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Transaction Date',
                  hintText: 'Select date',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: _pickDate,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Select transaction date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Submit Button
              ElevatedButton.icon(
                onPressed: _submitPayment,
                icon: const Icon(Icons.check),
                label: const Text('Add Payment'),
                style: ElevatedButton.styleFrom(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
