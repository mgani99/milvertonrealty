import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:milvertonrealty/payment/controller/payment_controller.dart';
import 'package:milvertonrealty/payment/view/payment_history_screen.dart';
import 'package:milvertonrealty/propertysetup/controller/propertyUnitController.dart';
import 'package:provider/provider.dart';



class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _debitOrCreditController = TextEditingController();
  final TextEditingController _paymentMethodController = TextEditingController();
  final TextEditingController _tenantIdController = TextEditingController();
  final TextEditingController _transactionTypeController = TextEditingController();
  final TextEditingController _unitIdController = TextEditingController();

  DateTime? selectedDate;

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _debitOrCreditController.dispose();
    _paymentMethodController.dispose();
    _tenantIdController.dispose();
    _transactionTypeController.dispose();
    _unitIdController.dispose();
    super.dispose();
  }

  void _submitPayment() {
    if (_formKey.currentState!.validate()) {
      double amount = double.parse(_amountController.text);
      String debitOrCredit = _debitOrCreditController.text;
      String paymentMethod = _paymentMethodController.text;
      int tenantId = int.parse(_tenantIdController.text);
      String transactionType = _transactionTypeController.text;
      int unitId = int.parse(_unitIdController.text);
      DateTime dateOfTx = selectedDate ?? DateTime.now();

      Provider.of<PaymentProvider>(context, listen: false).addPayment(
        amount: amount,
        dateOfTx: dateOfTx,
        debitOrCredit: debitOrCredit,
        paymentMethod: paymentMethod,
        tenantId: tenantId,
        transactionType: transactionType,
        unitId: unitId,
      );

      // Clear the form fields.
      _amountController.clear();
      _dateController.clear();
      _debitOrCreditController.clear();
      _paymentMethodController.clear();
      _tenantIdController.clear();
      _transactionTypeController.clear();
      _unitIdController.clear();
      selectedDate = null;
      Navigator.of(context).pop();
    }
  }

  void _showAddPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Payment"),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: "Amount"),
                  validator: (value) => value == null || value.isEmpty ? "Enter amount" : null,
                ),
                TextFormField(
                  controller: _debitOrCreditController,
                  decoration: InputDecoration(labelText: "Debit or Credit (debit/credit)"),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Enter debit or credit";
                    if (value.toLowerCase() != "debit" && value.toLowerCase() != "credit")
                      return "Enter only 'debit' or 'credit'";
                    return null;
                  },
                ),
                TextFormField(
                  controller: _paymentMethodController,
                  decoration: InputDecoration(labelText: "Payment Method"),
                  validator: (value) => value == null || value.isEmpty ? "Enter payment method" : null,
                ),
                TextFormField(
                  controller: _tenantIdController,
                  decoration: InputDecoration(labelText: "Tenant ID"),
                  validator: (value) => value == null || value.isEmpty ? "Enter tenant ID" : null,
                ),
                TextFormField(
                  controller: _transactionTypeController,
                  decoration: InputDecoration(labelText: "Transaction Type"),
                  validator: (value) => value == null || value.isEmpty ? "Enter transaction type" : null,
                ),
                TextFormField(
                  controller: _unitIdController,
                  decoration: InputDecoration(labelText: "Unit ID"),
                  validator: (value) => value == null || value.isEmpty ? "Enter unit ID" : null,
                ),
                TextFormField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: "Transaction Date",
                    hintText: "Select date",
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime now = DateTime.now();
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: now,
                      firstDate: DateTime(now.year - 10),
                      lastDate: DateTime(now.year + 10),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                      });
                    }
                  },
                  validator: (value) => value == null || value.isEmpty ? "Select transaction date" : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: Text("Add"),
            onPressed: _submitPayment,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rent Payment Tracking"),
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, provider, child) {
          if (provider.payments.isEmpty) {
            return Center(child: Text("No payments recorded."));
          }
          else {
            provider.buildPaymentByUnit(context);
          }
          return ListView.builder(
            itemCount: provider.unitData.length,
            itemBuilder: (context, index) {
              final unit = provider.unitData.toList()[index];
              return ListTile(
                title: Text("Payment: \$${unit['unitName']}"),
                subtitle: Text(
                      "Running Balance: \$${unit['balance'].toStringAsFixed(2)}",
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPaymentDialog,
        child: Icon(Icons.add),
        tooltip: "Add Payment",
      ),
    );
  }
}
