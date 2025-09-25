
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:milvertonrealty/common/service.dart';
import 'package:milvertonrealty/propertysetup/controller/propertyUnitController.dart';
import 'package:provider/provider.dart';

import '../components/month_mover.dart';
import '../route/route_constants.dart';
import '../theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

// Main application widget.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payment Tracker',
      theme: AppTheme.lightTheme(context),
      // Dark theme is inclided in the Full template
      themeMode: ThemeMode.light,
      home: PaymentListPage(),
    );
  }
}



///
/// Payment Model:
/// Represents a single payment record including a note field.
///
class Payment {
  String id;
  String unitNumber;
  String tenantId;
  DateTime date;
  double amount;
  String paymentType;      // e.g., Rent, Security Deposit, Late fee.
  String transactionType;
  String unitId;// "Credit" or "Debit"
  String note;             // Optional multiline note

  Payment({
    required this.id,
    required this.unitNumber,
    required this.tenantId,
    required this.date,
    //required this.rent,
    //required this.tenantName,
    required this.amount,
    required this.paymentType,
    required this.transactionType,
    required this.unitId,
    this.note = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'unitNumber': unitNumber,
      'tenantId': tenantId,
      'date': date.toIso8601String(),
      'amount': amount,
      'paymentType': paymentType,
      'transactionType': transactionType,
      'unitId' : unitId,
      'note': note,
    };
  }

  factory Payment.fromMap(String id, Map<dynamic, dynamic> map) {
    return Payment(
      id: id,
      unitNumber: map['unitNumber'] ?? '',
      tenantId: map['tenantId'] ?? '',
      date: DateTime.parse(map['date']),
      amount: (map['amount'] as num).toDouble(),
      paymentType: map['paymentType'] ?? '',
      transactionType: map['transactionType'] ?? 'Credit',
      unitId: map['unitId'] ?? '',
      note: map['note'] ?? '',
    );
  }
}

///
/// PaymentService:
/// Encapsulates all Firebase Realtime Database CRUD operations.
/// Data is stored in the grouping:
/// /payments/{unitNumber}/{tenantId}/{monthYear}/{paymentId}
///
class PaymentService {
  final DatabaseReference _dbRef =
  MR_DBService().getDBRef("Payments");


  // Compute grouping key from the date (month-year).
  String getMonthYear(DateTime date) {
    return DateFormat('MM-yyyy').format(date);
  }

  // Create a new payment record.
  Future<void> addPayment(Payment payment) async {
    String monthYear = getMonthYear(payment.date);
    DatabaseReference ref = _dbRef
        .child(payment.unitId)
        .push(); // Auto-generates a unique key.

    // Set payment id to the auto-generated key.
    payment.id = ref.key ?? '';
    await ref.set(payment.toMap());
  }

  // Retrieve all payment records (one-time call).
  Future<List<Payment>> getPayments() async {
    DataSnapshot snapshot = await _dbRef.get();
    List<Payment> payments = [];
    if (snapshot.value != null) {
      Map<dynamic, dynamic> unitNodes =
      snapshot.value as Map<dynamic, dynamic>;
      unitNodes..forEach((monthYear, paymentsMap) {
        if (paymentsMap is Map<dynamic, dynamic>) {
          paymentsMap.forEach((paymentId, paymentData) {
            Payment payment = Payment.fromMap(paymentId, paymentData);
            payments.add(payment);
          });
        }
      });

    }
    return payments;
  }

  // Stream of payments using onValue listener.
  Stream<List<Payment>> streamPayments() {
    return _dbRef.onValue.map((event) {
      List<Payment> payments = [];
      final data = event.snapshot.value;
      if (data != null) {
        Map<dynamic, dynamic> unitNodes = data as Map<dynamic, dynamic>;
        unitNodes.forEach((unitId, paymentsMap) {
          if (paymentsMap is Map<dynamic, dynamic>) {
            paymentsMap.forEach((paymentId, paymentData) {
              Payment payment = Payment.fromMap(paymentId, paymentData);
              payments.add(payment);
            });
          }
        });
      }
      return payments;
    });
  }

  // Update an existing payment record.
  Future<void> updatePayment(Payment payment) async {
    String monthYear = getMonthYear(payment.date);
    DatabaseReference ref = _dbRef
        .child(payment.unitId)
        .child(payment.id);
    await ref.update(payment.toMap());
  }

  // Delete a payment record.
  Future<void> deletePayment(Payment payment) async {
    String monthYear = getMonthYear(payment.date);
    DatabaseReference ref = _dbRef
        .child(payment.unitId)
        .child(payment.id);
    await ref.remove();
  }
}

///
/// PaymentListPage:
/// Displays payments grouped by unit number with tenant and month details in the header.
/// Uses a StreamBuilder to auto-refresh when data changes.
///
class PaymentListPage extends StatefulWidget {
  @override
  _PaymentListPageState createState() => _PaymentListPageState();

}


class _PaymentListPageState extends State<PaymentListPage> {
  final PaymentService _paymentService = PaymentService();
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredUnitData = [];
  List<Map<String, dynamic>> fullyPaidUnits = [];
  List<Map<String, dynamic>> partiallyPaidUnits = [];
  List<Map<String, dynamic>> unitData = [];
  List<Map<String, dynamic>> searchData = [];
  late DateTime paymentMonth; //set this date to see historical Payment



  // Group payments by unit number.
  Map<String, List<Payment>> _groupPayments(List<Payment> payments, BuildContext ctx) {
    Map<String, List<Payment>> groupedPayments = {};


    for (var payment in payments) {
      String unitNumber = payment.unitNumber;
      if (groupedPayments.containsKey(unitNumber)) {
        groupedPayments[unitNumber]!.add(payment);
      } else {
        groupedPayments[unitNumber] = [payment];
      }
    }


    return groupedPayments;
  }

  // Open the PaymentFormPage for adding a new payment.
  void _openAddPaymentForm(Map<String, dynamic> unitData) async {
    Payment payment = Payment(id: DateTime.now().hashCode.toString(), unitNumber: unitData['unitName'],
        tenantId: unitData['tenantId'].toString(), unitId: unitData['unitId'].toString(),
        date: DateTime.now(), amount: 0, paymentType: "Rent", transactionType: "Debit");
    await Navigator.push(

      context,
      MaterialPageRoute(
        builder: (_) => PaymentFormPage(paymentService: _paymentService,payment: payment),
      ),
    );
    // StreamBuilder will update automatically.
  }

  // Open the PaymentFormPage for editing an existing payment.
  void _openEditPaymentForm(Payment payment) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentFormPage(
          paymentService: _paymentService,
          payment: payment,
        ),
      ),
    );
    // Updates handled by the stream.
  }

  // Delete a payment record.
  void _deletePayment(Payment payment) async {
    await _paymentService.deletePayment(payment);
    // The stream updates automatically.
  }

  /// Updates the filtered list of items based on the current search query.
  void _filterData() {
    String query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      setState(() {


        searchData = unitData.where((item) {

          String unitNumber = (item['unitName'] ?? "").toLowerCase();
          String tName = (item['tenantName'] ?? "").toLowerCase();
          return !item['isVacant'] &&
              tName.contains(query) ||
          unitNumber.contains(query);
        }).toList();

  });
          }
      }


  /// Builds the title widget of the AppBar.
  Widget _buildAppBarTitle() {
    if (_isSearching) {
      return TextField(
        controller: _searchController,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Search items...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.white70),
        ),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
      );
    } else {
      return const Text('Payment Tracker');
    }
  }
  @override
  void initState() {
    super.initState();

    // Listen for changes in the search text field
    _searchController.addListener(_filterData);
    paymentMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<PropertySetupController>(context, listen: true);
    unitData = controller.unitData;
    if (unitData.isEmpty) {
      controller.getProperty();
    }
    filteredUnitData = filterVacantUnit(unitData);
    return Scaffold(
      appBar: AppBar(

          title: _buildAppBarTitle(),
         // backgroundColor: Colors.white,
       // foregroundColor: Colors.black,
        actions: [ _isSearching
            ? IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchController.clear();
              // Reset filtered list when exiting search mode
              filteredUnitData = List.from(unitData);
            });
          },
        )
            : IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = true;
            });
          },
        ),

        ],

      ),
      body: StreamBuilder<List<Payment>>(
        stream: _paymentService.streamPayments(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          List<Payment> payments = snapshot.data ?? [];
          if (_isSearching) {
            filteredUnitData = searchData;
          }
          // Group payments by unit number.
          Map<String, List<Payment>> groupedPayments = _groupPayments(payments, context);

          return RefreshIndicator(
            onRefresh: () async {
              // Manual refresh: Stream updates automatically.
              return;
            },
            child: Column(
              children: [
                Card(
                  color: Colors.grey,
                  margin: EdgeInsets.all(2.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(1.0))),
                  elevation: 4,

                  child: _buildTotalCard(filteredUnitData, groupedPayments),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(8.0),
                    itemCount: filteredUnitData.length,
                    itemBuilder: (BuildContext context, int index) {

                        String unitNumber = filteredUnitData[index]['unitName'];
                        String tname = filteredUnitData[index]['isVacant'] ? "Vacant " : filteredUnitData[index]['tenantName'];
                        String rent = filteredUnitData[index]['rent'].toString();
                        String paid = getPaidThisMonth(groupedPayments[unitNumber]).toString();
                        double pastDue = getPastDueAmount(groupedPayments[unitNumber]);
                        String sec = filteredUnitData[index]['securityDeposit'].toString();
                        double bal=getBalance(groupedPayments[unitNumber]);


                        // For subtitle, we show tenant and month details from first payment.

                        //Payment? firstPayment =entry.value.isEmpty? null : entry.value.first;
                       return  GestureDetector(
                         onDoubleTap: () {
                           showConfirmationDialog(
                             context: context,
                             title: 'Debit Rent',
                             message: 'Sure - Debit a Rent for ${filteredUnitData[index]['unitName']}',
                             onConfirmed: () {
                               // Your action here

                               Payment payment = Payment(
                                   id: '',
                                   unitNumber: filteredUnitData[index]['unitName'],
                                   tenantId: filteredUnitData[index]['tenantId'].toString(),
                                   date: DateTime.now(),
                                   amount: double.parse(rent),
                                   unitId: filteredUnitData[index]['unitId'].toString(),
                                   paymentType: "Rent",
                                   transactionType: "Debit",
                                   note: "test - remove"
                               );
                               _paymentService.addPayment(payment);
                             },
                           );

                         },
                         child: Card(
                            elevation: 8,

                            child: ExpansionTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Text(
                                    "Unit: $unitNumber (${tname})",

                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                              SizedBox(height: 5,),
                              Text(
                                "Rent:\$${rent} (Due on:${filteredUnitData[index]['dueDate']})",
                                style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                                  SizedBox(height: 5,),
                                  Text("Past Due:\$${pastDue}", style: TextStyle(fontSize: 14, color: (pastDue < 0) ? Colors.red : Colors.grey[900])),

                                ],
                              ),
                              subtitle:Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(height: 20),
                                  Text('Paid:\$${paid}', style: TextStyle(fontSize: 16, color:Colors.grey[700])),
                                  Spacer(flex:1),
                                  Text('Bal:\$${bal}', style: TextStyle(fontSize: 16, color: (bal < 0) ? Colors.red : Colors.grey[700])),
                                ],
                              ),
                              //trailing:


                              children: getTransactionList(groupedPayments[unitNumber], filteredUnitData[index]),
                            ),

                          ),
                       );



                      }),
                ),
              ],
            ),

            );

        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _openAddPaymentForm,
      //   child: Icon(Icons.add),
      // ),
    );
  }



  Widget _buildTotalCard(List<Map<String, dynamic>> unitData, Map<String, List<Payment>> groupedPayments) {
    int totalPaidInFull = 0;
    double totalExpected = 0.0;
    double received = 0.0;
    double balance = 0.0;
    int totalRentedUnit = 0;
    double totalRcvd = 0.0;
    NumberFormat numberFormat = NumberFormat("#,##0", "en_US");
    partiallyPaidUnits=[];
    fullyPaidUnits = [];
    for (int i = 0; i < unitData.length; i++) {

      String unitNumber = unitData[i]['unitName'];
      if (unitData[i]['isVacant']) continue;
      if (getBalance(groupedPayments[unitNumber]) >=0 ) {
        print('paid full ${unitNumber}');
        fullyPaidUnits.add(unitData[i]);
        ++totalPaidInFull;
        received = received + getPaidThisMonth(groupedPayments[unitNumber]);
      }
      else {
        partiallyPaidUnits.add(unitData[i]);
      }
      ++totalRentedUnit;
      totalRcvd = totalRcvd + getPaidThisMonth(groupedPayments[unitNumber]);
      totalExpected = totalExpected + unitData[i]['rent'];
      balance = balance + getBalance(groupedPayments[unitNumber]);
          //+ getPastDueAmount(groupedPayments[unitNumber]);
    }

      return Padding(
        padding: const EdgeInsets.all(1.0),
        child: Column(
          //margin: EdgeInsets.all(10.0),
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[

            Container(

                height: 105,
                width: MediaQuery
                    .of(context)
                    .size
                    .width - 4,
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildUserStatsItem(
                          "${totalRentedUnit}",
                          "Unit Rented",
                          "\$${(numberFormat.format(totalExpected))}",
                          "Expected",
                          Colors.blue[200]!,
                          0
                          ),
                      _buildUserStatsItem(
                          "${totalPaidInFull}",
                          "Paid Full",
                          "\$${(numberFormat.format(received))}",
                          "Received",
                          Colors.green[200]!,
                          1
                          ),
                      _buildUserStatsItem(
                          "${unitData.length - totalPaidInFull}",
                          "Partly Paid",
                          "\$${(numberFormat.format(totalRcvd - received))}",
                          "Amount",
                          Colors.purple[200]!,
                          2),
                      _buildUserStatsItem(
                          "\$${numberFormat.format(totalRcvd)}",
                          "Total Rcvd",
                          "\$${ numberFormat.format(balance) }",
                          "Balance",
                          Colors.cyan[200]!,
                          2),
                    ])
            ),
            MonthYearNavigator(
              onDateChanged: (DateTime newDate) {
                //print('Date changed: $newDate'); // React to the date change
                paymentMonth = newDate;
                setState(() {
                  paymentMonth;
                });
              }, currentDate: paymentMonth,
            ),

          ],
        ),
      );

  }
  int chosenBox = 0;
  _buildUserStatsItem(String s, String t, String s2, String t2, Color c, int index) {

    return InkWell(


      onTap: () {
        //setState(() {chosenBox = index;getTxSummaryList(prop);getTxSummaryListFiltered(key, props);p
        print(index);
        setState(() {
          if (index == 1 )filteredUnitData = fullyPaidUnits;

          if (index == 2) filteredUnitData = partiallyPaidUnits;

        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 6,
              offset: Offset(0, 3), // Shadow offset
            ),
          ],
          color: c,
          border: chosenBox == index?  Border.all(color: Colors.blue, width: 3) :Border.all(color: Colors.white) ,
        ),
        height: 100,
        width: (MediaQuery.of(context).size.width/4)-10,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(s, style: TextStyle(fontSize: 14, color: Colors.black)),
            Text(t, style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(.7))),
            SizedBox(height: 8,),
            Text(s2, style: TextStyle(fontSize: 14, color: Colors.black)),
            //SizedBox(height: 3),
           Text(t2, style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(.7))),

          ],
        ),
      ),
    );
  }
  Future<void> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirmed,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('No'),
            ),
            SizedBox(height: 10,),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      onConfirmed(); // Only executes if user tapped "Yes"
    }
  }

  List<Widget> getTransactionList(List<Payment>? unitPayment, Map<String, dynamic> unitData) {
    List<Widget> retVal = [];
    if (unitPayment == null || unitPayment.isEmpty) {
      retVal.add(_buildTxTitleTail(unitData));
      return retVal;
    }
    unitPayment.sort((a, b) => a.date.compareTo(b.date));
    retVal.add(_buildTxTitleTail(unitData));
    for (Payment payment in unitPayment) {
      retVal.add(
          RentPaymentCard(payment: payment,)
          /*Card(
            child: ListTile(
              title: Text("${payment.paymentType}  ${payment.transactionType == "Credit" ? "Charged" : "Paid"} - ${payment.date}"),
              subtitle: Text("${payment.amount.toStringAsFixed(2)}"),
              trailing: Row(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         IconButton(
                           icon: Icon(Icons.edit, color: Colors.blue),
                           onPressed: () => _openEditPaymentForm(payment),
                         ),
                         IconButton(
                           icon: Icon(Icons.delete, color: Colors.red),
                           onPressed: () => _deletePayment(payment),
                         ),
                       ],
                     ),
            ),
          ),*/);

      //     subtitle: Column(
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       children: [
      //         Text('${DateFormat('dd/MM/yyyy').format(payment.date)}'),
      //         if (payment.note.isNotEmpty)
      //           Padding(
      //             padding: const EdgeInsets.only(top: 4.0),
      //             child: Text(
      //               'Note: ${payment.note}',
      //               style: TextStyle(fontStyle: FontStyle.italic),
      //             ),
      //           ),
      //       ],
      //     ),
      //     trailing: Row(
      //       mainAxisSize: MainAxisSize.min,
      //       children: [
      //         IconButton(
      //           icon: Icon(Icons.edit, color: Colors.blue),
      //           onPressed: () => _openEditPaymentForm(payment),
      //         ),
      //         IconButton(
      //           icon: Icon(Icons.delete, color: Colors.red),
      //           onPressed: () => _deletePayment(payment),
      //         ),
      //       ],
      //     ),
      //   );
      // }).toList(),
    }

    return retVal;
  }

  Widget _buildTxTitleTail(Map<String, dynamic> unitData) {
    return Card(

      //width: MediaQuery.of(context).size.width * 0.95,

      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.all(2.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      IconButton(
                        //  label: Text("", style: const TextStyle(fontSize: 12,)),
                        onPressed:() { unitData['isVacant'] ? print('pressed') :  _openAddPaymentForm(unitData);},
                        icon: const Icon(Icons.monetization_on_sharp),),
                      Spacer(flex: 1),
                      IconButton(
                        //label: Text("",  style: const TextStyle(fontSize: 12,)),
                          onPressed: () {
                             Navigator.pushNamed(context, unitSetupScreen,
                              arguments: unitData);
                            },

                            icon :
                            const Icon(Icons.edit_document),



                      ),

                      Spacer(flex: 1),
                      IconButton(
                        //label: Text("",  style: const TextStyle(fontSize: 12,)),
                          onPressed: () {
                            print("sms");},
                          icon : const Icon(Icons.sms_rounded)

                      ),
                    ])
            ),
          ],
        ),
      ),
    );


  }

  emptyCard() {}

  double getBalance(List<Payment>? groupedPayment) {
    if (groupedPayment == null || groupedPayment.isEmpty) return 0.0;
    double retVal = 0.0;
    for (Payment payment in groupedPayment) {
      if (payment.transactionType == 'Credit' && payment.date.month <= paymentMonth.month) {
        retVal = retVal - payment.amount;
      }
      else if (payment.transactionType == 'Debit' && payment.date.month <= paymentMonth.month) {
        retVal = retVal + payment.amount;
      }
    }
    return retVal;
  }
  bool isDateInCurrentMonth(DateTime date) {

    return date.year == paymentMonth.year && date.month == paymentMonth.month;
  }
  
  double getPaidThisMonth(List<Payment>? groupedPayment) {
    if (groupedPayment == null || groupedPayment.isEmpty) return 0.0;
    double retVal = 0.0;
    for (Payment payment in groupedPayment) {

       if (payment.transactionType == 'Debit' && isDateInCurrentMonth(payment.date)) {
        retVal = retVal + payment.amount;
      }
    }
    return retVal;
  }

  double getPastDueAmount(List<Payment>? groupedPayment) {
    if (groupedPayment == null || groupedPayment.isEmpty) return 0.0;
    double retVal = 0.0;
    for (Payment payment in groupedPayment) {

      if (payment.transactionType == 'Credit' && payment.date.month < paymentMonth.month) {
        retVal = retVal - payment.amount;
      }
      if (payment.transactionType == 'Debit' && payment.date.month < paymentMonth.month) {
        retVal = retVal + payment.amount;
      }

    }
    return retVal;


  }



  List<Map<String, dynamic>> filterVacantUnit(List<Map<String, dynamic>> unitData) {
    List<Map<String,dynamic>> retVal = [];
    unitData.forEach((element) {
      if (!element['isVacant']) {
          retVal.add(element);
        }
    });
    return retVal;
  }
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

///
/// PaymentHistoryPage:
/// Displays all payments in a flat, chronological list with options to edit and delete each record.
///
class PaymentHistoryPage extends StatefulWidget {
  final PaymentService paymentService;

  PaymentHistoryPage({required this.paymentService});

  @override
  _PaymentHistoryPageState createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  List<Payment> _payments = [];

  @override
  void initState() {
    super.initState();
    _fetchPaymentHistory();
  }

  Future<void> _fetchPaymentHistory() async {
    List<Payment> payments = await widget.paymentService.getPayments();
    // Sort payments by date descending.
    payments.sort((a, b) => b.date.compareTo(a.date));
    setState(() {
      _payments = payments;
    });
  }

  // Navigate to edit a payment.
  void _editPayment(Payment payment) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentFormPage(
          paymentService: widget.paymentService,
          payment: payment,
        ),
      ),
    );
    _fetchPaymentHistory();
  }

  // Delete a payment and refresh list.
  void _deletePayment(Payment payment) async {
    await widget.paymentService.deletePayment(payment);
    _fetchPaymentHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment History'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchPaymentHistory,
        child: ListView.builder(
          padding: EdgeInsets.all(8.0),
          itemCount: _payments.length,
          itemBuilder: (context, index) {
            final payment = _payments[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 6.0),
              child: ListTile(
                title: Text(
                  '${payment.paymentType} (${payment.transactionType}) - \$${payment.amount.toStringAsFixed(2)}',
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Unit: ${payment.unitNumber}, Tenant: ${payment.tenantId}'),
                    Text('Date: ${DateFormat('dd/MM/yyyy').format(payment.date)}'),
                    if (payment.note.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Note: ${payment.note}',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editPayment(payment),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),


                      onPressed: () {

                        _deletePayment(payment);
                        },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

///
/// PaymentFormPage:
/// A form to add or update a payment record, including a multi-line note field.
///
class PaymentFormPage extends StatefulWidget {
  final PaymentService paymentService;
  final Payment? payment;

  PaymentFormPage({required this.paymentService, this.payment});

  @override
  _PaymentFormPageState createState() => _PaymentFormPageState();
}

class _PaymentFormPageState extends State<PaymentFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _unitNumberController;
  late TextEditingController _tenantIdController;
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  DateTime _selectedDate = DateTime.now();
  String _paymentType = 'Rent';
  String _transactionType = 'Credit';
  String unitId = "";

  final List<String> _paymentTypes = ['Rent', 'Security Deposit', 'Late fee'];
  final List<String> _transactionTypes = ['Credit', 'Debit'];

  @override
  void initState() {
    super.initState();
    _unitNumberController = TextEditingController(
        text: widget.payment != null ? widget.payment!.unitNumber : '');
    _tenantIdController = TextEditingController(
        text: widget.payment != null ? widget.payment!.tenantId : '');
    _amountController = TextEditingController(
        text: widget.payment != null ? widget.payment!.amount.toString() : '');
    _noteController = TextEditingController(
        text: widget.payment != null ? widget.payment!.note : '');
    _selectedDate = widget.payment != null ? widget.payment!.date : DateTime.now();
    _paymentType = widget.payment != null ? widget.payment!.paymentType : _paymentType;
    _transactionType =
    widget.payment != null ? widget.payment!.transactionType : 'Credit';
    unitId = widget.payment != null ? widget.payment!.unitId : "";
  }

  @override
  void dispose() {
    _unitNumberController.dispose();
    _tenantIdController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _savePayment() async {
    if (_formKey.currentState!.validate()) {
      double? amount = double.tryParse(_amountController.text);
      if (amount == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Please enter a valid amount')));
        return;
      }
      Payment payment = Payment(
        id: widget.payment != null ? widget.payment!.id : '',
        unitNumber: _unitNumberController.text,
        tenantId: _tenantIdController.text,
        date: _selectedDate,
        amount: amount,
        unitId: unitId,
        paymentType: _paymentType,
        transactionType: _transactionType,
        note: _noteController.text,
      );
      if (widget.payment == null) {
        await widget.paymentService.addPayment(payment);
      } else {
        await widget.paymentService.updatePayment(payment);
      }
      Navigator.pop(context);
    }
  }
  void _deletePayment(Payment payment) async {
    await widget.paymentService.deletePayment(payment);
    Navigator.pop(context);
    // The stream updates automatically.
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        Text(widget.payment == null ? 'Add Payment' : 'Edit Payment'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _unitNumberController,
                decoration: InputDecoration(labelText: 'Unit Number'),
                readOnly: true,
                validator: (value) =>
                value == null || value.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 8,),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType:
                TextInputType.numberWithOptions(decimal: true),
                validator: (value) =>
                value == null || value.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 8,),
              DropdownButtonFormField<String>(
                value: _paymentType,
                decoration: InputDecoration(labelText: 'Payment Type'),
                items: _paymentTypes
                    .map((type) =>
                    DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _paymentType = value;
                    });
                  }
                },
              ),
              SizedBox(height: 8,),
              DropdownButtonFormField<String>(
                value: _transactionType,
                decoration: InputDecoration(labelText: 'Transaction Type'),
                items: _transactionTypes
                    .map((type) =>
                    DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _transactionType = value;
                    });
                  }
                },
              ),
              SizedBox(height: 8,),
              // Multi-line Note Field.
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Note',
                  hintText: 'Enter additional details about the payment',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              ListTile(
                title: Text(
                  'Payment Date: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _savePayment,
                child: Text(
                    widget.payment == null ? 'Add Payment' : 'Update Payment'),
              ),
              SizedBox(height: 12,),
              widget.payment != null ? ElevatedButton(
                onPressed: () {
                  _deletePayment(widget.payment!);
                },
                child: Text(
                     'Delete Payment', style: TextStyle(color: Colors.redAccent),),
              ) : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }


}

class RentPaymentCard extends StatelessWidget {
  final Payment payment;
 // True for credit, false for debit

  RentPaymentCard({
    required this.payment,

  });

  @override
  Widget build(BuildContext context) {
    return Card(
      //elevation: 2,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(1),



      ),
      child: InkWell(
        onTap: () {
           Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentFormPage(
                paymentService: PaymentService(),
                payment: payment,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon section
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: payment.transactionType == "Credit" ? Colors.red.shade100 : Colors.green.shade100,
                ),
                child: Icon(
                  payment.transactionType == "Credit" ? Icons.arrow_downward : Icons.arrow_upward,
                  color: payment.transactionType == "Credit" ? Colors.red : Colors.green,
                ),
              ),
              SizedBox(width: 16), // Spacing between icon and details
              // Details section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                    DateFormat('MMM/d/yy').format(payment.date),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,

                      ),
                    ),
                    Text(
                      payment.paymentType,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              // Amount section
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    payment.transactionType == "Credit" ? 'Charged' : 'Tenant Paid',
                    style: TextStyle(
                      fontSize: 14,
                      color: payment.transactionType == "Credit" ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${payment.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),


            ],
          ),
        ),
      ),

    );
  }
}
