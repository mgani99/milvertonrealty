import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:milvertonrealty/payment/controller/payment_controller.dart';
import 'package:milvertonrealty/payment/domain/payment.dart';
import 'package:provider/provider.dart';

class PaymentHistoryScreen extends StatelessWidget {
  final Payment payment;

  PaymentHistoryScreen(this.payment);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Payment History: Unit ${payment.unitId}")),
      body: Consumer<PaymentProvider>(
        builder: (context, provider, child) {
          List<List<Payment>> updatedPayment = provider.payments.toList();
          return ListView.builder(
            itemCount: updatedPayment.length,
            itemBuilder: (context, index) {
              final record = updatedPayment[index];
              return ListTile(
                title: Text("Amount: "),
                subtitle: Text("Date: "),
              );
            },
          );
        },
      ),
    );
  }
}