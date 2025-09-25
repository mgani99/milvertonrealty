// lib/screens/user_list_screen.dart
import 'package:flutter/material.dart';
import 'package:milvertonrealty/user/view/user_card.dart';
import 'package:provider/provider.dart';
import '../controller/user_provider.dart';


class UserListScreen extends StatelessWidget {
  const UserListScreen();
  @override
  Widget build(BuildContext context) {
    final prov = context.watch<UserProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: prov.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: prov.users.length,
        itemBuilder: (_, i) => UserCard(user: prov.users[i]),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(context, '/edit'),
      ),
    );
  }
}
