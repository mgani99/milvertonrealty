import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class PlaidService {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseDatabase.instance;

  /// Fetches a Plaid link_token from Firebase backend
  static Future<String?> fetchLinkToken() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;

    final response = await http.post(
      Uri.parse(
        'https://us-central1-YOUR_PROJECT.cloudfunctions.net/createLinkToken',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['link_token'];
    } else {
      print('Error fetching link token: ${response.body}');
      return null;
    }
  }

  /// Exchanges public_token for access_token and saves it to Realtime DB
  static Future<void> exchangePublicToken(
      String publicToken,
      String userId,
      ) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://us-central1-YOUR_PROJECT.cloudfunctions.net/exchangePublicToken',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'public_token': publicToken}),
      );

      if (response.statusCode == 200) {
        final accessToken = jsonDecode(response.body)['accessToken'];
        await _db.ref('plaidTokens/$userId').set({'accessToken': accessToken});
      } else {
        print('Exchange error: ${response.body}');
      }
    } catch (e) {
      print('Exception during exchange: $e');
    }
  }
}
