

import 'package:milvertonrealty/common/domain/base_domain.dart';

/// Payment model class.
class Payment extends BaseDomain {
  static String rootDBLocation = "Payments/";
  final double amount;
  double balance; // This will be computed as a running balance.
  final DateTime dateOfTx;
  final String debitOrCredit; // "debit" or "credit"
  final String paymentMethod;
  final int tenantId;
  final String transactionType;
  final int unitId;

  Payment(super.id,{

    required this.amount,
    this.balance = 0.0,
    required this.dateOfTx,
    required this.debitOrCredit,
    required this.paymentMethod,
    required this.tenantId,
    required this.transactionType,
    required this.unitId,
  });

  factory Payment.fromMap(String id, Map<dynamic, dynamic> map) {
    return Payment(
      id.hashCode,
      amount: (map['amount'] != null) ? double.parse(map['amount'].toString()) : 0.0,
      dateOfTx: DateTime.tryParse(map['dateOfTx'].toString()) ?? DateTime.now(),
      debitOrCredit: map['debitOrCredit'] ?? 'credit',
      paymentMethod: map['paymentMethod'] ?? '',
      tenantId: map['tenantId'] ?? 0,
      transactionType: map['transactionType'] ?? '',
      unitId: map['unitId'] ?? 0,
    );
  }
  @override
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'dateOfTx': dateOfTx.toIso8601String(),
      'debitOrCredit': debitOrCredit,
      'paymentMethod': paymentMethod,
      'tenantId': tenantId,
      'transactionType': transactionType,
      'unitId': unitId,
    };
  }

  @override
  String getObjDBLocation() {
    // TODO: implement getObjDBLocation
    return Payment.rootDBLocation;
  }

}