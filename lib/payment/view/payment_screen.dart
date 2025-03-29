import 'package:flutter/material.dart';

void main() {
  runApp(PaymentTrackerApp());
}

class PaymentTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PaymentTrackerHomePage(),
    );
  }
}

class PaymentTrackerHomePage extends StatelessWidget {
  //const PaymentTrackerHomePage({super.key});
  final List<Map<String, dynamic>> paymentInfo = [
    {
      'unitNumber': 'Unit 101',
      'tenantName': 'John Doe',
      'rentAmount': 1200,
      'balance': 200,
      'history': [
        {'date': '01 Jan 2025', 'amount': 1000},
        {'date': '01 Feb 2025', 'amount': 1000},
      ],
    },
    {
      'unitNumber': 'Unit 102',
      'tenantName': 'Jane Smith',
      'rentAmount': 1500,
      'balance': 0,
      'history': [
        {'date': '01 Jan 2025', 'amount': 1500},
        {'date': '01 Feb 2025', 'amount': 1500},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Tracker'),
        backgroundColor: Colors.grey,
      ),
      body: ListView.builder(
        itemCount: paymentInfo.length,
        itemBuilder: (context, index) {
          final payment = paymentInfo[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ExpansionTile(
              title: Text(
                payment['unitNumber'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tenant: ${payment['tenantName']}'),
                  Text('Rent: \$${payment['rentAmount']}'),
                  Text('Balance: \$${payment['balance']}'),
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment History:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...payment['history'].map<Widget>((transaction) {
                        return ListTile(
                          leading: Icon(Icons.history),
                          title: Text('Date: ${transaction['date']}'),
                          subtitle:
                          Text('Amount: \$${transaction['amount']}'),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
