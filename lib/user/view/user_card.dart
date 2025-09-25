// lib/widgets/user_card.dart
import 'package:flutter/material.dart';
import 'package:milvertonrealty/common/domain/user.dart';
import 'package:milvertonrealty/user/controller/user_provider.dart';
import 'package:milvertonrealty/user/view/user_form_screen.dart';
import 'package:provider/provider.dart';


class UserCard extends StatelessWidget {
  final ReUser user;
  const UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final prov = context.read<UserProvider>();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(user.name),
        subtitle: Text('${user.emailAddress} • ${user.userType}'),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserFormScreen(existing: user),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),

              onPressed: ()  {user.status = 'Deleted';prov.updateUser(user);},
            ),
          ],
        ),
      ),
    );
  }


}
