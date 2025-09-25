import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:milvertonrealty/common/service.dart';

Future<void> uploadCsvFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['csv']);

  if (result != null) {
    File file = File(result.files.single.path!);
    String content = await file.readAsString();
    List<List<dynamic>> rows = CsvToListConverter().convert(content);

    for (var row in rows.skip(1)) {  // Skip header
      var expense = {
        "details" : row[0],
        "posting_date": row[1],
        "description": row[2],
        "amount": row[3],
        "type": row[4],
        "balance": row[5]
      };
      MR_DBService().getDBRef("Expense/uncategorized").push().set(expense);
    }
  }
}