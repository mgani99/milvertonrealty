

import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:milvertonrealty/common/service.dart';
import 'package:milvertonrealty/payment/domain/payment.dart';
import 'package:milvertonrealty/propertysetup/controller/propertyUnitController.dart';
import 'package:provider/provider.dart';

class PaymentProvider extends ChangeNotifier {
  Map<int, List<Payment>> _payments = {};//Unit id,

  List<Map<String, dynamic>> unitData = [];

  List<List<Payment>> get payments => _payments.values.toList();

  late DatabaseReference _paymentRef;
  StreamSubscription<DatabaseEvent>? _paymentSubscription;

  PaymentProvider() {
    _paymentRef = MR_DBService().getDBRef(Payment.rootDBLocation);
    //final unitController = Provider.of<PropertySetupController>(context, listen: false);
    _listenToPayments();
  }

  /// Listen for realtime updates in the "payments" node.
  void _listenToPayments() {

    _paymentSubscription = _paymentRef.onValue.listen((event) {
      final dataSnapshot = event.snapshot;
      Map<int, List<Payment>> paymentMap = {};
      if (dataSnapshot.value != null) {
        // Firebase returns a Map
        Map<dynamic, dynamic> paymentsMap = dataSnapshot.value as Map<
            dynamic,
            dynamic>;
        paymentsMap.forEach((key, value) {
          Payment payment = Payment.fromMap(
              key, value as Map<dynamic, dynamic>);
          if (paymentMap.containsKey(value['unitId'])) {
            final paymentsForUnit = paymentMap[value['unitId']] ?? [];
            paymentsForUnit.add(payment);
          }
        });
        // Sort payments by transaction date.

      }
      _payments = paymentMap;
      notifyListeners();
    });
  }

  void buildPaymentByUnit(BuildContext ctx) {
   final  controller = Provider.of<PropertySetupController>(ctx, listen: false);
    unitData = controller.unitData;
  unitData.forEach(( value) {
  final unitJson = value;
  if (_payments.containsKey(unitJson['unitId'])) {
    unitJson['payments'] = [];
    unitJson['payments'] = _payments[unitJson['unitId']];
    final paymentList = _payments[unitJson['unitId']] as  List ?? [];
     paymentList.sort((a, b) => a.dateOfTx.compareTo(b.dateOfTx));

        // Compute the running balance.
        double runningBalance = 0.0;
        for (var payment in paymentList) {
          if (payment.debitOrCredit.toLowerCase() == 'credit') {
            runningBalance += payment.amount;
          } else if (payment.debitOrCredit.toLowerCase() == 'debit') {
            runningBalance -= payment.amount;
          }
          payment.balance = runningBalance;
        }
        unitJson['balance'] = runningBalance;
   }
  });

}





Future<void> addPayment({
    required double amount,
    required DateTime dateOfTx,
    required String debitOrCredit,
    required String paymentMethod,
    required int tenantId,
    required String transactionType,
    required int unitId,
  }) async {
    DatabaseReference newPaymentRef = _paymentRef.push();
    Payment newPayment = Payment(
      newPaymentRef.key.hashCode ?? 0,
      amount: amount,
      dateOfTx: dateOfTx,
      debitOrCredit: debitOrCredit,
      paymentMethod: paymentMethod,
      tenantId: tenantId,
      transactionType: transactionType,
      unitId: unitId,
    );

    await newPaymentRef.set(newPayment.toJson());
    // The realtime listener (_listenToPayments) will update the list automatically.
  }

  @override
  void dispose() {
    _paymentSubscription?.cancel();
    super.dispose();
  }
}