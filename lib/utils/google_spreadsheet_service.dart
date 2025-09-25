import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart'     as drive;
import 'package:googleapis/sheets/v4.dart'    as sheets;
import 'package:http/http.dart' as http;

import 'dart:async';
import 'package:http/http.dart' as http;

/// Injects OAuth headers into every request.
class GoogleHttpClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  GoogleHttpClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }
}


class GoogleSheetsService {
  final _scopes = <String>[
    drive.DriveApi.driveReadonlyScope,
    sheets.SheetsApi.spreadsheetsReadonlyScope,
  ];

  final GoogleSignIn _gsign = GoogleSignIn(scopes:  <String>[
    drive.DriveApi.driveReadonlyScope,
    sheets.SheetsApi.spreadsheetsReadonlyScope,
  ]);

  Future<GoogleHttpClient> _getClient() async {
    // prompt user to pick a Google account
    final account = await _gsign.signInSilently() ?? await _gsign.signIn();
    if (account == null) {
      throw Exception('Google sign-in aborted');
    }
    final headers = await account.authHeaders;
    return GoogleHttpClient(headers);
  }

  Future<drive.DriveApi> _driveApi() async {
    final client = await _getClient();
    return drive.DriveApi(client);
  }

  Future<sheets.SheetsApi> _sheetsApi() async {
    final client = await _getClient();
    return sheets.SheetsApi(client);
  }

  Future<List<List<Object?>>?> readSheetValues(
      String spreadsheetId,
      String range,
      ) async {
    final api = await _sheetsApi();
    final resp = await api.spreadsheets.values.get(spreadsheetId, range);
    // Each row is a List<Object?>, cells may be null if empty
    return resp.values;
  }

}
