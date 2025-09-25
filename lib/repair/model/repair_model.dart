
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:milvertonrealty/common/model/common_model.dart';
import 'package:milvertonrealty/common/service.dart';

import '../../common/domain/user.dart';



class RepairModel extends BaseModel {

  static String categoryRoot = "RepairCategories/";
  Future<Map<String, List<String>>> getRepairCategory() async {
    try {
      // Access the "categories" node in the database
      final DataSnapshot snapshot = await MR_DBService().getDBRef(categoryRoot).get();

      // Check if data exists
      if (snapshot.exists) {
        final rawData = Map<String, dynamic>.from(snapshot.value as Map);

        // Convert to Map<String, List<String>>
        return rawData.map((key, value) =>
            MapEntry(key, List<String>.from(value as List)));
      } else {
        print("No data found!");
        return {};
      }
    } catch (e) {
      print("Error fetching data: $e");
      return {};
    }
  }


}

class ContractorAndOwner {
  final String id;
  final String name;
  ContractorAndOwner({required this.id, required this.name});
}

class Issue {
  static String categoryRoot = "Repairs/";
  final String id;
  final String unit;
  final String description;
  final DateTime dateLogged;
  final DateTime? dateCompleted;
  final DateTime? scheduleDate;
  final String contractorId;
  final String contractorName;
  final String ownerId;
  final String ownerName;
  final double cost;
  final String status;        // Open, In Progress, Completed
  final String paymentStatus; // Pending, Paid
  final String tenantId;
  final String tenantName;

  final double partialAmount;


  Issue({
    required this.id,
    required this.unit,
    required this.description,
    required this.dateLogged,
    required this.dateCompleted,
    required this.contractorId,
    required this.contractorName,
    required this.ownerId,
    required this.ownerName,
    required this.cost,
    required this.status,
    required this.paymentStatus,
    required this.tenantId,
    required this.tenantName,
    required this.scheduleDate,
    required this.partialAmount,
  });

  factory Issue.fromSnapshot(DataSnapshot snap) {
    final m = Map<String, dynamic>.from(snap.value as Map);
    return Issue(
      id: snap.key!,
      unit: m['unit'] as String,
      description: m['description'] as String,
      dateLogged: DateTime.parse(m['dateLogged']?.toString() ?? ''),
      dateCompleted:m['dateCompleted'] != null
          ? DateTime.parse(m['dateCompleted'].toString())
          : null,
      scheduleDate:m['scheduleDate'] != null
          ? DateTime.parse(m['scheduleDate'].toString())
          : null,
      contractorId: m['contractorId']?.toString() ?? '',
      contractorName: (m['contractorName'] ?? '') as String,
      ownerId:  m['ownerId']?.toString() ?? '',
      ownerName: (m['ownerName'] ?? '') as String,
      cost: (m['cost'] as num).toDouble(),
      partialAmount: (m['partialAmount']?? 0.0).toDouble(),
      status: m['status'] as String,
      paymentStatus: m['paymentStatus'] as String,
      tenantId: m['tenantId']?.toString()?? '',
      tenantName: (m['tenantName']?? '') as String,


    );
  }
}

class IssueRepository {
  final DatabaseReference _issuesRef = MR_DBService().getDBRef(Issue.categoryRoot);


  /// Helper to convert a Realtime Database query into a broadcast
  /// Stream<List<Issue>> for safe multi-listening.
  Stream<List<Issue>> _map(Query query) {
    return query
        .onValue
        .map((event) {
      if (event.snapshot.value == null) return <Issue>[];
      return event.snapshot.children
          .map(Issue.fromSnapshot)
          .toList();
    })
        .asBroadcastStream();
  }

  // ─── Tenant Streams ─────────────────────────────────────────

  /// All issues for a given unit (open, in-progress, completed).
  Stream<List<Issue>> tenantIssues(String unit) {
    return _map(_issuesRef.orderByChild('unit').equalTo(unit));
  }

  Future<Map<String, List<ContractorAndOwner>>> fetchUsersByRole() async {
    final ref = MR_DBService().getDBRef(ReUser.userRootDB);
    final snapshot = await ref.get();
    final raw = snapshot.value as Map<dynamic, dynamic>? ?? {};

    final Map<String, List<ContractorAndOwner>> grouped = {};

    for (final entry in raw.entries) {
      final data = Map<String, dynamic>.from(entry.value);
      final type = data['userType']?.toString() ?? "None";
      if (type != 'Contractor' && type != 'Owner') continue;

      final user = ContractorAndOwner(
        id: entry.key.toString(),
        name: data['name']?.toString() ?? '',
        // populate any other fields you need…
      );

      grouped.putIfAbsent(type, () => []).add(user);
    }

    return grouped;
  }
  /// Only completed issues for a given unit.
  Stream<List<Issue>> tenantCompleted(String unit) {
    return tenantIssues(unit)
        .map((list) => list.where((i) => i.status == 'Completed').toList());
  }

  // ─── Contractor Streams ─────────────────────────────────────

  /// Issues assigned to this contractor (not completed).
  Stream<List<Issue>> contractorAssigned(String contractorId) {
    return _map(
      _issuesRef.orderByChild('contractorId').equalTo(contractorId),
    ).map((list) => list.where((i) => i.status != 'Completed').toList());
  }

  /// Open issues without any contractor assigned.
  Stream<List<Issue>> contractorAvailable() {
    return _map(
      _issuesRef.orderByChild('status').equalTo('Open'),
    ).map((list) => list.where((i) => i.contractorId.isEmpty).toList());
  }

  // ─── Owner Streams ──────────────────────────────────────────

  /// Every issue in the system.
  Stream<List<Issue>> ownerAll() {
    return _map(_issuesRef);
  }

  Stream<List<Issue>> newUnassignedIssue() {
    return _map(_issuesRef.orderByChild('ownerId').equalTo('') );
  }
  /// Every issue in the system.
  Stream<List<Issue>> ownerAssigned(String ownerId) {
    return _map(_issuesRef.orderByChild('ownerId').equalTo(ownerId),
    ).map((list) => list.where((i) => i.status != 'Completed').toList());
  }

  // ─── Mutations ──────────────────────────────────────────────

  /// Pushes a new issue under `/issues`. Returns the generated key.
  Future<String> createIssue(Map<String, dynamic> data) async {

    /*
          description: m['description'] as String,
      dateLogged: DateTime.parse(m['dateLogged']?.toString() ?? ''),
      dateCompleted:m['dateCompleted'] != null
          ? DateTime.parse(m['dateCompleted'].toString())
          : null,
      scheduleDate:m['scheduleDate'] != null
          ? DateTime.parse(m['scheduleDate'].toString())
          : null,
      contractorId: m['contractorId']?.toString() ?? '',
      contractorName: (m['contractorName'] ?? '') as String,
      ownerId:  m['ownerId']?.toString() ?? '',
      ownerName: (m['ownerName'] ?? '') as String,
      cost: (m['cost'] as num).toDouble(),
      partialAmount: (m['partialAmount']?? 0.0).toDouble(),
      status: m['status'] as String,
      paymentStatus: m['paymentStatus'] as String,
      tenantId: m['tenantId']?.toString()?? '',
      tenantName: (m['tenantName']?? '') as String,
     */



    data['status']        ??= 'Open';
    data['paymentStatus'] ??= 'Unpaid';
    data['dateLogged']    ??= DateTime.now().toUtc().toIso8601String();

    final newRef = _issuesRef.push();
    await newRef.set(data);
    return newRef.key!;
  }

  /// Updates arbitrary fields on an existing issue.
  Future<void> updateIssue(
      String issueId,
      Map<String, dynamic> updates,
      ) {
    return _issuesRef.child(issueId).update(updates);
  }

  Future<void> assignToOwner(
      String issueId,
      String ownerId,
      String ownerName,
      ) {
    return _issuesRef.child(issueId).update({
      'ownerId': ownerId,
      'contractorName': ownerName,

    });
  }

  /// Assigns the issue to a contractor and marks it in-progress.
  Future<void> assignToContractor(
      String issueId,
      String contractorId,
      String contractorName,
      ) {
    return _issuesRef.child(issueId).update({
      'contractorId': contractorId,
      'contractorName': contractorName,
      'status': 'Scheduled',
    });
  }

  /// Toggles or sets the status of an issue. Automatically stamps completed date.
  Future<void> updateStatus(String issueId, String status) {
    final updates = {'status': status};
    if (status == 'Completed') {
      updates['dateCompleted'] = DateTime.now().toUtc().toIso8601String();
    }
    return _issuesRef.child(issueId).update(updates);
  }

  /// Marks the issue as paid or pending.
  Future<void> updatePayment(String issueId, String paymentStatus) {
    return _issuesRef
        .child(issueId)
        .update({'paymentStatus': paymentStatus});
  }

  Future<void> deleteIssue(String id) async {
    try {
      await _issuesRef.child(id).remove();
    } on FirebaseException catch (e) {
      // You can log this or wrap it in your own exception type
      print('Error deleting issue $id: ${e.message}');
      rethrow;
    }
  }


 }


class IssueFilters {
  final String status; // All/Open/In Progress/Completed
  final List<String> unitQueries; // e.g. ['Unit 1', 'Unit 2']
  final String paymentStatus; // All/Pending/Paid
  final DateTime? from;
  final DateTime? to;
  final String query; // description search
  final String? ownerId;

  const IssueFilters({
    this.status = 'All',
    this.unitQueries = const ['All'],
    this.paymentStatus = 'All',
    this.from,
    this.to,
    this.query = '',
    this.ownerId = '',
  });

  IssueFilters copyWith({
    String? status,
    List<String>? unitQueries,
    String? paymentStatus,
    DateTime? from,
    DateTime? to,
    String? query,
    String? ownerId,
  }) =>
      IssueFilters(
        status: status ?? this.status,
        unitQueries: unitQueries ?? this.unitQueries,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        from: from ?? this.from,
        to: to ?? this.to,
        query: query ?? this.query,
        ownerId: ownerId ?? this.ownerId,
      );
}
List<Issue> applyFilters(List<Issue> issues, IssueFilters f) {
  final normalizedUnits = f.unitQueries.map((u) => u.toLowerCase()).toList();
  final unitFilterActive = !(normalizedUnits.length == 1 && normalizedUnits.first == 'all');

  return issues.where((i) {
    final unitMatch = !unitFilterActive || normalizedUnits.contains(i.unit.toLowerCase());

    final statusOk = f.status == 'All' || i.status == f.status;
    final payOk = f.paymentStatus == 'All' || i.paymentStatus == f.paymentStatus;

    final fromOk = f.from == null ||
        i.dateLogged.isAfter(f.from!) ||
        i.dateLogged.isAtSameMomentAs(f.from!);

    final toOk = f.to == null ||
        i.dateLogged.isBefore(f.to!) ||
        i.dateLogged.isAtSameMomentAs(f.to!);

    final qOk = f.query.isEmpty ||
        i.description.toLowerCase().contains(f.query.toLowerCase());

    final ownerOk = f.ownerId == '' || f.ownerId == i.ownerId;

    return unitMatch && statusOk && payOk && fromOk && toOk && qOk && ownerOk;
  }).toList();
}



/*
class IssueFilters {
  final String status;
  final String unitQuery;// All/Open/In Progress/Completed
  final String paymentStatus; // All/Pending/Paid
  final DateTime? from;
  final DateTime? to;
  final String query;
  final String? ownerId;
  // description search

  const IssueFilters({
    this.status = 'All',
    this.unitQuery = 'All',
    this.paymentStatus = 'All',
    this.from,
    this.to,
    this.query = '',
    this.ownerId ='',

  });

  IssueFilters copyWith({
    String? status,
    String? paymentStatus,
    String? unitQuery,
    DateTime? from,
    DateTime? to,
    String? query,
    String? ownerId,

  }) => IssueFilters(
    status: status ?? this.status,
    unitQuery: unitQuery ?? this.unitQuery,
    paymentStatus: paymentStatus ?? this.paymentStatus,
    from: from ?? this.from,
    to: to ?? this.to,
    query: query ?? this.query,
    ownerId: ownerId ?? this.ownerId,
  );
}

List<Issue> applyFilters(List<Issue> issues, IssueFilters f) {
  return issues.where((i) {
    final matchesUnit =f.unitQuery.toLowerCase() == 'all' || f.unitQuery.isEmpty ||
        i.unit.toLowerCase().contains(f.unitQuery.toLowerCase());
    final statusOk = f.status == 'All' || i.status == f.status;
    final payOk = f.paymentStatus == 'All' || i.paymentStatus == f.paymentStatus;
    final fromOk = f.from == null || i.dateLogged.isAfter(f.from!) || i.dateLogged.isAtSameMomentAs(f.from!);
    final toOk = f.to == null || i.dateLogged.isBefore(f.to!) || i.dateLogged.isAtSameMomentAs(f.to!);
    final qOk = f.query.isEmpty || i.description.toLowerCase().contains(f.query.toLowerCase());
    final propOwner = f.ownerId == '' || f.ownerId == i.ownerId;
    return statusOk && payOk && fromOk && toOk && qOk && matchesUnit && propOwner;
  }).toList();
}


*/