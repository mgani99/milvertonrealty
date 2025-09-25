import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

Future<void> main() async {
  // Ensure Flutter’s widget framework is initialized before calling Firebase code.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // References to our database paths.
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
  final DatabaseReference tenantLeadsRef = databaseRef.child('tenant_leads');
  final DatabaseReference backupRef = databaseRef.child('tenant_leads_backup');

  try {
    // Retrieve all tenant leads from the source folder.
    final DataSnapshot snapshot = await tenantLeadsRef.get();

    if (snapshot.exists) {
      // Expecting the data to be stored as a map of key/value pairs.
      final Map<dynamic, dynamic> leads =
      snapshot.value as Map<dynamic, dynamic>;

      // Iterate over each tenant lead.
      for (final entry in leads.entries) {
        final String key = entry.key.toString();
        final Map<dynamic, dynamic> originalRecord =
        Map<dynamic, dynamic>.from(entry.value);

        // Write the **original** record to the backup folder.
        await backupRef.child(key).set(originalRecord);
        print('Backed up original record with key: $key');

        // Extract fields with default values where applicable.
        final String name = originalRecord['name']?.toString() ?? '';
        String phoneNumber = originalRecord['phoneNumber']?.toString() ?? '';
        final dynamic salary = originalRecord['salary'];
        final bool hasSection8 = originalRecord['hasSection8'] ?? false;
        final String avaialabilityDate =
            originalRecord['avaialabilityDate']?.toString() ?? '';
        String status = originalRecord['status']?.toString() ?? '';
        final String scheuleTime =
            originalRecord['scheuleTime']?.toString() ?? '';
        final String description =
            originalRecord['description']?.toString() ?? '';
        final String photoUrl = originalRecord['photoUrl']?.toString() ?? '';
        final dynamic timeStamp = originalRecord['timeStamp'];

        // Transform the phone number to 10 digits. Adjust this logic if non-numeric
        // characters or other processing is needed.
        if (phoneNumber.length > 10) {
          phoneNumber = phoneNumber.substring(phoneNumber.length - 10);
        }

        // If the status field is blank (empty or whitespace), set a default value.
        if (status.trim().isEmpty) {
          status = "Pending";
        }

        // Create a transformed record including the new fields.
        final Map<String, dynamic> transformedRecord = {
          'name': name,
          'phoneNumber': phoneNumber,
          'salary': salary,
          'hasSection8': hasSection8,
          'avaialabilityDate': avaialabilityDate,
          'status': status,
          'scheuleTime': scheuleTime,
          'description': description,
          'photoUrl': photoUrl,
          'timeStamp': timeStamp, // Preserve the original timeStamp.
          'createTimeStamp': timeStamp, // Copy to createTimeStamp.
          'updateTimeStamp': timeStamp, // Copy to updateTimeStamp.
        };

        // Write the **transformed** record back to the tenant_leads folder.
        await tenantLeadsRef.child(key).set(transformedRecord);
        print('Updated tenant_leads record with transformed data for key: $key');
      }
      print('Migration complete. All records processed.');
    } else {
      print('No tenant leads found in the source folder.');
    }
  } catch (e) {
    print('Error during migration: $e');
  }
}
