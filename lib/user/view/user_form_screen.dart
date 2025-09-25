import 'package:flutter/material.dart';
import 'package:milvertonrealty/common/domain/user.dart';
import 'package:provider/provider.dart';
import '../controller/user_provider.dart';

class UserFormScreen extends StatefulWidget {
  final ReUser? existing;
  const UserFormScreen({Key? key, this.existing}) : super(key: key);

  @override
  _UserFormScreenState createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  String _role = 'Tenant';
  String _status = 'Active';

  final List<String> _statusOptions = ['Active', 'Inactive', 'Delete'];
  late List<bool> _selectedStatus;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _emailCtrl = TextEditingController(text: widget.existing?.emailAddress ?? '');
    _role = widget.existing?.userType ?? 'Tenant';
    _status = widget.existing?.status ?? 'Active';
    _selectedStatus = _statusOptions.map((s) => s == _status).toList();
  }

  void _onStatusToggle(int index) {
    setState(() {
      _selectedStatus = List.generate(_statusOptions.length, (i) => i == index);
      _status = _statusOptions[index];
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final prov = context.read<UserProvider>();

    final user = ReUser(
      widget.existing?.id ?? 0,
      name: _nameCtrl.text.trim(),
     // fireBaseId : widget.existing?.fireBaseId,
      emailAddress: _emailCtrl.text.trim(),
      userType: _role,
      createdAt: widget.existing?.createdAt ?? DateTime.now().millisecondsSinceEpoch,
      lastLogin: DateTime.now().millisecondsSinceEpoch,
      status: _status,
    );
    user.fireBaseId = widget.existing?.fireBaseId?? "";
    widget.existing == null
        ? prov.createUser(user.name, user.emailAddress, user.userType, user.status)
        : prov.updateUser(user);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit User' : 'Create User'),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditing ? 'Update User Info' : 'Enter New User Details',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 24),

                          TextFormField(
                            controller: _nameCtrl,
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _emailCtrl,
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: const Icon(Icons.email),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            validator: (v) => v != null && v.contains('@') ? null : 'Enter a valid email',
                          ),
                          const SizedBox(height: 16),

                          DropdownButtonFormField<String>(
                            value: _role,
                            decoration: InputDecoration(
                              labelText: 'User Role',
                              prefixIcon: const Icon(Icons.security),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            items: ['Owner', 'Contractor', 'Tenant']
                                .map((role) => DropdownMenuItem(
                              value: role,
                              child: Text(role[0].toUpperCase() + role.substring(1)),
                            ))
                                .toList(),
                            onChanged: (value) => setState(() => _role = value ?? 'Tenant'),
                          ),
                          const SizedBox(height: 32),

                          Text('Status', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          ToggleButtons(
                            isSelected: _selectedStatus,
                            onPressed: _onStatusToggle,
                            borderRadius: BorderRadius.circular(8),
                            selectedColor: Colors.white,
                            fillColor: Colors.blueGrey,
                            color: Colors.blueGrey,
                            constraints: const BoxConstraints(minHeight: 40, minWidth: 90),
                            children: _statusOptions.map((label) => Text(label)).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _save,
                  ),
                ),
              ],
            )

          ),
        ),
      ),
    );
  }
}
