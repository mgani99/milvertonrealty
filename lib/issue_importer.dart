import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

// Replace with your actual import path to the Issue class:
import 'package:milvertonrealty/common/domain/Repair.dart';
import 'package:milvertonrealty/common/service.dart';
import 'package:milvertonrealty/repair/model/repair_model.dart';

/// Simple CLI: dart run bin/import_issues.dart path/to/WorkOrders2025.csv
  Future<void> loadIssue() async {
  /*if (args.isEmpty) {
    print('Usage: dart run import_issues.dart <csv-file-path>');
    exit(1);
  }*/

  final csvPath = "C:\\Users\\Public\\Issues.csv";
  print("loading ${csvPath}");
  if (!File(csvPath).existsSync()) {
    print('File not found: $csvPath');
    //exit(2);
  }

  // Initialize Firebase
  await Firebase.initializeApp();
  final db = FirebaseDatabase.instance.ref();
  // Issue.categoryRoot is "Repairs/"
  final repairsRef = MR_DBService().getDBRef(Issue.categoryRoot);

 // await _importCsv(csvPath, repairsRef);
  print('✅ Import complete.');
  exit(0);
}

Future<void> importCSV(List rows, DatabaseReference repairsRef) async {
  // final input = File(filePath).openRead();
  // final rows = await input
  //     .transform(utf8.decoder)
  //     .transform(const CsvToListConverter())
  //     .toList();

  // Extract header names and map to column indices
  final headers = rows.first.map((cell) => cell.toString().trim()).toList();
  int idx(String name) => headers.indexOf(name);

  final dateFmt = DateFormat('M/d/yyyy');

  for (var i = 1; i < rows.length; i++) {
    final row = rows[i].map((c) => c.toString().trim()).toList();

    // Build Issue fields
    final unit            = row[idx('Unit#')];
    final description     = row[idx('Description')];
    final rawLogged       = row.length > idx('Date Logged') ? row[idx('Date Logged')] : '9/14/2025';
    final rawCompleted    = row.length> idx('Date Completed') ? row[idx('Date Completed')] : '9/14/2025';
    final rawContractor   = row.length > idx('Contractor') ? row[idx('Contractor')] : 'Unassigned';
    final rawOwner        = row.length > idx('Owner') ? row[idx('Owner')] : 'Unassigned';
    final rawCost         = row.length > idx('Cost') ? row[idx('Cost')] : '0.0';
    final rawStatus       = row.length > idx('Status') ? row[idx('Status')] : 'Open';
    final rawPayment      = row.length > idx('Payment Status') ? row[idx('Payment Status')] : 'Unpaid';

    // Parse dates
    DateTime parseDate(String s) {
      if (s.isEmpty) return DateTime.now();
      try {
        return dateFmt.parse(s);
      } catch (_) {
        return DateTime.now();
      }
    }

    final dateLogged    = parseDate(rawLogged);
    final dateCompleted = rawCompleted.isEmpty ? null : parseDate(rawCompleted);

    // Name mappings
    String ownerId = "0";
    String contractorId = "0";
    String mapContractorName(String n) {
      switch (n) {
        case 'Gani':{
          contractorId = "13902317";
          return 'Mohammed Gani';
          }
        case 'Faisol':
          contractorId = '51239163';
          return 'Faisol Islam';
        case 'Tanweer':
          contractorId = '532933366';
          return 'Tanweer Zaman';
        case 'Malik' :
          contractorId = "218139660";
          return "Malik Floyd";
        case 'Harold' :
          contractorId = "369802749";
          return "Harold Davenport";
        case 'Peter' :
          contractorId = "346751537";
          return "Peter Ayala";
        default:
          return n;
      }
    }
    String mapOwnerName(String n) {
      switch (n) {
        case 'Gani':{
          ownerId = '228343804';
          return 'Mohammed Gani';
        }
        case 'Faisol':
          ownerId = '247692296';
          return 'Faisol Islam';
        case 'Tanweer':
          ownerId = '283146316';
          return 'Tanweer Zaman';
        default:
          return n;
      }
    }

    final contractorName = mapContractorName(rawContractor);
    final ownerName      = mapOwnerName(rawOwner);


    // Normalize status & payment
    String normalizeStatus(String s) {
      final v = s.toLowerCase();
      if (v.contains('progress')) return 'Scheduled';
      if (v.contains('completed') || v == 'done') return 'Completed';
      return 'Open';
    }

    String normalizePayment(String s) {
      final v = s.toLowerCase();
      return v == 'paid' ? 'Paid' : 'Pending';
    }

    final status        = normalizeStatus(rawStatus);
    final paymentStatus = normalizePayment(rawPayment);

    // Cost parsing
    final cost = double.tryParse(rawCost) ?? 0.0;

    // Build the JSON payload
    final newIssueRef = repairsRef.push();
    final issueId     = newIssueRef.key!;
    final payload = {
      'id'             : issueId,
      'unit'           : unit,
      'description'    : description,
      'dateLogged'     : dateLogged.toIso8601String(),
      'dateCompleted'  : dateCompleted?.toIso8601String(),
      'scheduleDate'   : null,
      'contractorId'   : contractorId,
      'contractorName' : contractorName,
      'ownerId'        : ownerId,
      'ownerName'      : ownerName,
      'cost'           : cost,
      'status'         : status,
      'paymentStatus'  : paymentStatus,
      'partialAmount'  : 0.0,
    };

    await newIssueRef.set(payload);
    print('→ imported row ${i} as Issue ID ${payload}');
  }
}
