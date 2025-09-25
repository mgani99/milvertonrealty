import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:plaid_flutter/plaid_flutter.dart';

class PlaidLinkLauncher extends StatefulWidget {
  const PlaidLinkLauncher({super.key});

  @override
  State<PlaidLinkLauncher> createState() => _PlaidLinkLauncherState();
}

class _PlaidLinkLauncherState extends State<PlaidLinkLauncher> {
  bool _loading = false;
  String? _error;

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseDatabase.instance;

  @override
  void initState() {
    super.initState();

    // Register Plaid callbacks
    PlaidLink.onSuccess((publicToken, metadata) async {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _exchangePublicToken(publicToken, userId);
        if (mounted) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Bank linked successfully")),
          );
        }
      }
    });

    PlaidLink.onExit((error, metadata) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = error?.displayMessage ?? "Plaid exited unexpectedly.";
        });
      }
    });

    PlaidLink.onEvent((eventName, metadata) {
      debugPrint("Plaid event: $eventName");
    });
  }

  Future<void> _startPlaidFlow() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      setState(() {
        _loading = false;
        _error = "User not authenticated.";
      });
      return;
    }

    final linkToken = await _fetchLinkToken(userId);
    if (linkToken == null) {
      setState(() {
        _loading = false;
        _error = "Failed to fetch link token.";
      });
      return;
    }

    await PlaidLink.open(
      configuration: LinkTokenConfiguration(token: linkToken),
    );
  }

  Future<String?> _fetchLinkToken(String userId) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://us-central1-YOUR_PROJECT.cloudfunctions.net/createLinkToken',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode == 200) {
        final linkToken = jsonDecode(response.body)['link_token'];

        // ✅ Save to Realtime Database
        await _db.ref('plaidLinkTokens/$userId').set({
          'linkToken': linkToken,
          'timestamp': DateTime.now().toIso8601String(),
        });

        return linkToken;
      } else {
        debugPrint('Error fetching link token: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Exception fetching link token: $e');
      return null;
    }
  }

  Future<void> _exchangePublicToken(
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
        debugPrint('Exchange error: ${response.body}');
      }
    } catch (e) {
      debugPrint('Exception during exchange: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _loading ? null : _startPlaidFlow,
          child: _loading
              ? const CircularProgressIndicator()
              : const Text("Connect Bank"),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }
}
