// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:milvertonrealty/common/domain/user.dart';
import 'package:milvertonrealty/user/view/user_card.dart';
import 'package:provider/provider.dart';
import '../controller/user_provider.dart';
import 'package:milvertonrealty/user/view/user_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreen createState() => _DashboardScreen();
}

class _DashboardScreen extends State<DashboardScreen> {
  ReUser? selectedUser;
  String _searchQuery = '';
  bool _showAll = false;  // toggles inclusion of Deleted users

  List<ReUser> _applyFilters(List<ReUser> users) {
    // 1) Filter by status: show only Active & Inactive unless _showAll is true
    final statusFiltered = _showAll
        ? users
        : users.where((u) =>
    u.status.toLowerCase() == 'active' ||
        u.status.toLowerCase() == 'inactive').toList();

    // 2) Apply search query on the already status-filtered list
    if (_searchQuery.isEmpty) return statusFiltered;
    final q = _searchQuery.toLowerCase();
    return statusFiltered.where((u) {
      return u.name.toLowerCase().contains(q) ||
          u.emailAddress.toLowerCase().contains(q) ||
          u.userType.toLowerCase().contains(q) ||
          u.status.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allUsers = context.watch<UserProvider>().users;
    final users = _applyFilters(allUsers);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
      ),

      body: Column(
        children: [
          // ─── Search Field ─────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name, email, role or status…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _searchQuery = ''),
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // ─── Show All Toggle ───────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Show All Users'),
                  selected: _showAll,
                  onSelected: (val) => setState(() => _showAll = val),
                  selectedColor: Colors.blueGrey.shade100,
                ),
              ],
            ),
          ),

          // ─── User List ────────────────────────────
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final isSelected = user == selectedUser;

                return InkWell(
                  onTap: () => setState(() => selectedUser = user),
                  child: Container(
                    color: isSelected ? Colors.blueGrey.shade50 : null,
                    child: ListTile(
                      title: Text(user.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${user.emailAddress} • ${user.userType}'),
                      trailing: Text(user.status,
                          style: TextStyle(
                              color: user.status.toLowerCase() == 'active'
                                  ? Colors.green
                                  : user.status.toLowerCase() == 'inactive'
                                  ? Colors.orange
                                  : Colors.red)),
                    ),
                  ),
                );
              },
            ),
          ),

          // ─── Detail Card ──────────────────────────
          if (selectedUser != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: UserCard(user: selectedUser!),
            ),
        ],
      ),

      // ─── Add New User FAB ──────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UserFormScreen()),
        ),
        backgroundColor: Colors.blueGrey,
        tooltip: 'Add New User',
        child: const Icon(Icons.person_add_alt_1),
      ),
    );
  }
}
