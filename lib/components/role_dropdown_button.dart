import 'package:flutter/material.dart';

import '../common/domain/user.dart';
class ReUserDropdownButton extends StatelessWidget {
  final List<ReUser> users;
  final ReUser currentUser;
  final ValueChanged<ReUser> onUserChanged;

  const ReUserDropdownButton({
    Key? key,
    required this.users,
    required this.currentUser,
    required this.onUserChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ReUser>(
      tooltip: 'Switch User',

      // Use `child` instead of `icon` so we can combine avatar + arrow
      child: Row(

        children: [
          // Circle with initials or profile image
          CircleAvatar(
            backgroundImage: currentUser.profilePictureURL.isNotEmpty
                ? NetworkImage(currentUser.profilePictureURL)
                : null,
            backgroundColor: Colors.grey.shade300,
            child: currentUser.profilePictureURL.isEmpty
                ? Text(
              _initials(currentUser.name) + "[" +currentUser.userType + "]",
              style: TextStyle(fontWeight: FontWeight.bold),
            )
                : null,
          ),

          const SizedBox(width: 4),

          // Tiny dropdown arrow
          Icon(
            Icons.arrow_drop_down,
            size: 20,
            color: Theme.of(context).iconTheme.color,
          ),
        ],
      ),

      onSelected: onUserChanged,

      itemBuilder: (context) {
        return users.map((user) {
          return PopupMenuItem<ReUser>(
            value: user,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: user.profilePictureURL.isNotEmpty
                      ? NetworkImage(user.profilePictureURL)
                      : null,
                  child: user.profilePictureURL.isEmpty
                      ? Text(
                    _initials(user.name),
                    style: TextStyle(fontSize: 12),
                  )
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(user.name),

                ),
                Text(
                  user.userType,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (user.defaultUserType)
                  Icon(Icons.check, color: Colors.green, size: 18),
              ],
            ),
          );
        }).toList();
      },

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 4,
      offset: Offset(0, 48),
    );
  }

  String _initials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return parts[0][0] + parts[1][0];
    }
    return name.substring(0, 1);
  }
}
