import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:milvertonrealty/repair/view/summary_chart.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../home/controller/app_data.dart';
import '../controller/repair_controller.dart';
import '../model/repair_model.dart';

import 'issue_card.dart';
import 'issue_filter_bar.dart';
import 'issue_screen.dart';


class RoleDashboard extends StatefulWidget {
  const RoleDashboard({Key? key}) : super(key: key);

  @override
  State<RoleDashboard> createState() => _RoleDashboardState();
}

class _RoleDashboardState extends State<RoleDashboard> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();


  /// Builds the title widget of the AppBar.
  ///
  @override
  void initState() {
    super.initState();



  }


  Widget _buildAppBarTitle() {
    if (_isSearching) {
      return TextField(
        controller: _searchController,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Search Description...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.white70),
        ),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
      );
    } else {
      return const Text('Issue Dashboard');
    }
  }
  @override
  Widget build(BuildContext context) {
    // Pull controller; rebuild on notifyListeners()
    final ctrl = Provider.of<RepairController>(context, listen: false);
    AppData appData = Provider.of<AppData>(context);
    return  DefaultTabController(
      length: ctrl.getTabs(appData.settings['role'].toString().toLowerCase()).length,
      child: Builder(
        builder: (context) {
          final tabController = DefaultTabController.of(context);
          tabController.addListener(() {
            if (tabController.indexIsChanging) {
              // Reset filters when tab is switching
              ctrl.resetFilter(appData.settings['role'].toString().toLowerCase(), tabController.index);
            }
          });

          return Scaffold(
            appBar: AppBar(
              title: _buildAppBarTitle(),
              actions: [
                _isSearching
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _searchController.clear();
                    });
                  },
                )
                    : IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                ),
              ],
              bottom: TabBar(
                tabs: ctrl.getTabs(appData.settings['role'].toString().toLowerCase()),
              ),
            ),
            floatingActionButton: (appData.settings['role'].toString().toLowerCase() == 'tenant' ||
                appData.settings['role'].toString().toLowerCase() == 'owner')
                ? FloatingActionButton(
              onPressed: () => _onNewIssue(context, appData),
              backgroundColor: Colors.transparent,
              elevation: 0,
              shape: const CircleBorder(),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.all(12),
                child: const Icon(Icons.add, color: Colors.black),
              ),
            )
                : null,
            body: TabBarView(
              children: List.generate(
                ctrl.getTabs(appData.settings['role'].toString().toLowerCase()).length,
                    (i) {
                  if (appData.settings['role'].toString().toLowerCase() == 'owner' && i == 3) {
                    return SummaryTab(stream: ctrl.repo.ownerAll());
                  }
                  return _StreamPane(index: i, appData: appData);
                },
              ),
            ),
          );
        },
      ),
    );

  }

  Future<void> _onSearch(BuildContext context) async {
    // TODO: wire up your search – for example:
    // final results = await showSearch<String>(
    //   context: context,
    //   delegate: IssueSearchDelegate(),
    // );
    // if (results != null) {
    //   final ctrl = Provider.of<RepairController>(context, listen: false);
    //   ctrl.updateFilters(ctrl.filters.copyWith(search: results));
    // }
  }

  Future<void> _onNewIssue(
      BuildContext context, AppData appData) async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => NewUpdateIssueScreen(

        ),
      ),
    );
    if (created == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Issue created')),
      );
    }
  }


}


class _StreamPane extends StatelessWidget {
  final int index;
  final AppData appData;
  const _StreamPane({Key? key, required this.index, required this.appData }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ctrl = Provider.of<RepairController>(context, listen: true);

    return StreamBuilder<List<Issue>>(
      stream: ctrl
          .streamFor(index, appData)
          .map((list) => applyFilters(list, ctrl.filters)),
      builder: (context, snap) {
        final issues = snap.data ?? [];

        return Column(
          children: [
            FilterBar(
              filters: ctrl.filters,
              index: index,
              onChanged: ctrl.updateFilters,
              issueCount: issues.length, // ✅ now passed correctly
            ),
            const Divider(height: 0),
            Expanded(
              child: snap.connectionState == ConnectionState.waiting
                  ? const Center(child: CircularProgressIndicator())
                  : issues.isEmpty
                  ? const Center(child: Text('No issues found.'))
                  : ListView.builder(
                itemCount: issues.length,
                itemBuilder: (context, i) {
                  final issue = issues[i];
                  return IssueCard(
                    issue: issue,
                    onTap: () => _openEditor(context, issue),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openEditor(BuildContext context, Issue issue) async {
    final ctrl = Provider.of<RepairController>(context, listen: false);
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => NewUpdateIssueScreen(existingIssue: issue),
        //builder: (context) => IssueScreen(issue: issue),
      ),
    );
    if (created == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Issue updated')),
      );
    }
  }
}



class NewUpdateIssueScreen extends StatefulWidget {
  final Issue? existingIssue;

  const NewUpdateIssueScreen({Key? key, this.existingIssue})
      : super(key: key);

  @override
  _NewUpdateIssueScreenState createState() => _NewUpdateIssueScreenState();
}

class _NewUpdateIssueScreenState extends State<NewUpdateIssueScreen> {
  late final RepairController _ctrl;
  final _formKey = GlobalKey<FormState>();

  // text controllers
  late final TextEditingController _unitCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _costCtrl;
  late final TextEditingController _partialCtrl;

  // form state
  String? _selectedContractorId;
  String? _selectedOwnerId;
  DateTime _dateLogged = DateTime.now();
  DateTime? _dateScheduled;
  DateTime? _dateCompleted;
  String _status = 'Open';
  String _paymentStatus = 'Unpaid';

  late final Future<List<ContractorAndOwner>> _contractorsFuture;
  late final Future<List<ContractorAndOwner>> _ownersFuture;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _ctrl = Provider.of<RepairController>(context, listen: false);
    final contractorsAndOwner =  _ctrl.repo.fetchUsersByRole();
    _contractorsFuture =  contractorsAndOwner.then((byRole) => byRole['Contractor'] ?? <ContractorAndOwner>[]);
    _ownersFuture =  contractorsAndOwner.then((byRole) => byRole['Owner'] ?? <ContractorAndOwner>[]);
    _unitCtrl = TextEditingController();
    _descCtrl = TextEditingController();
    _costCtrl = TextEditingController();
    // default partial paid := 0.0
    _partialCtrl = TextEditingController(text: '0.0');

    final appData = Provider.of<AppData>(context, listen: false);
    final issue = widget.existingIssue;

    // initialize unit field
    if (appData.settings['role'].toString().toLowerCase() == 'tenant') {
      _unitCtrl.text = appData.settings['unitName'];
    } else {
      _unitCtrl.text = issue?.unit ?? '';
    }

    if (issue != null) {
      _descCtrl.text = issue.description;
      _costCtrl.text = issue.cost.toStringAsFixed(2);
      _selectedContractorId =
      issue.contractorId.isNotEmpty ? issue.contractorId : null;
      _selectedOwnerId =
      issue.ownerId.isNotEmpty ? issue.ownerId : '0';
      _dateLogged = issue.dateLogged;
      _dateScheduled = issue.scheduleDate;
      _dateCompleted = issue.dateCompleted;
      _status = issue.status;
      _paymentStatus = issue.paymentStatus == 'Pending' ? "Unpaid" : issue.paymentStatus;

      // if existing issue had a partialAmount, show it
      if (issue.paymentStatus == 'Partly Paid' &&
          issue.partialAmount != null) {
        _partialCtrl.text = issue.partialAmount!.toStringAsFixed(2);
      }
    }
  }

  @override
  void dispose() {
    _unitCtrl.dispose();
    _descCtrl.dispose();
    _costCtrl.dispose();
    _partialCtrl.dispose();
    super.dispose();
  }




  Future<void> _pickDate({
    required DateTime initial,
    required DateTime firstDate,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final appData = Provider.of<AppData>(context, listen: false);
    final unitValue = appData.settings['role'].toString().toLowerCase() ==
        'tenant'
        ? appData.settings['unitName']
        : _unitCtrl.text.trim();
    List<ContractorAndOwner> owners = await _ownersFuture;
    List<ContractorAndOwner> contractors = await _contractorsFuture;
    final payload = <String, dynamic>{
      'unit': unitValue,
      'description': _descCtrl.text.trim(),
      'cost': _costCtrl.text.isEmpty ? 0.0 : double.parse(_costCtrl.text),
      'status': _status,
      'paymentStatus': _paymentStatus,
      'contractorId': _selectedContractorId ?? '',
      'ownerId' : _selectedOwnerId ?? '',
      'ownerName' : (_selectedOwnerId == "" || _selectedOwnerId == null  || _selectedOwnerId == "0") ?
    'Unassigned' : getNameById(_selectedOwnerId, owners,fallback: 'Unassigned'),
      'contractorName' :(_selectedContractorId == "" || _selectedContractorId == null) ?
           'Unassigned' : getNameById(_selectedContractorId, contractors,fallback: 'Unassigned'),

      if (widget.existingIssue == null)
        'dateLogged': _dateLogged.toUtc().toIso8601String(),
      if (_status == 'Scheduled' && _dateScheduled != null)
        'scheduleDate': _dateScheduled!.toUtc().toIso8601String(),
      if (_status == 'Completed' && _dateCompleted != null)
        'dateCompleted': _dateCompleted!.toUtc().toIso8601String(),
      if (_paymentStatus == 'Partly Paid')
        'partialAmount': double.tryParse(_partialCtrl.text.trim()) ?? 0.0,
    };

    try {
      if (widget.existingIssue == null) {
        await _ctrl.repo.createIssue(payload);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Issue created')));
      } else {
        await _ctrl.repo
            .updateIssue(widget.existingIssue!.id, payload);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Issue updated')));
      }
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() => _isSaving = false);
    }
  }
  String getNameById(String? id,List<ContractorAndOwner> contractors, {
        String fallback = '',
      }) {
    if (id == null || id.isEmpty) return fallback;
    final match = contractors.firstWhere(
          (c) => c.id == id,
      orElse: () => ContractorAndOwner(id: '', name: fallback),
    );
    return match.name;
  }

  Future<void> _confirmAndDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Issue'),
        content: const Text(
            'Are you sure you want to delete this issue? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // call your repository or controller to remove the issue
    try {
      // assuming you provided IssueRepository via RepairController
      final repo = context.read<RepairController>().repo;
      await repo.deleteIssue(widget.existingIssue!.id);

      // pop back once (close dialog), then again to leave edit screen
      if (mounted) {
        Navigator.of(context).pop(); // close edit screen
      }
    } catch (e) {
      // handle errors—e.g. show a Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFmt = DateFormat.yMd().add_jm();
    final appData = Provider.of<AppData>(context, listen: true);
    final isTenant =
        appData.settings['role'].toString().toLowerCase() == 'tenant';
    final isOwner =
        appData.settings['role'].toString().toLowerCase() == 'owner';

    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text,
          style: theme.textTheme.bodyMedium!
              .copyWith(fontWeight: FontWeight.w600)),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingIssue == null
            ? 'New Issue'
            : 'Edit Issue'),

      actions: [
          if (widget.existingIssue != null && isOwner)
    IconButton(
      icon: const Icon(Icons.delete, color: Colors.redAccent,),
      tooltip: 'Delete Issue',
      onPressed: _confirmAndDelete,

    ),
      ],),
      body: AbsorbPointer(
        absorbing: _isSaving,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Unit field
                if (!isTenant) ...[
                  label('Unit Number'),
                  TextFormField(
                    controller: _unitCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Enter unit',
                      filled: true,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Required'
                        : null,
                  ),
                ] else ...[
                  label('Unit'),
                  Text(_unitCtrl.text,
                      style: theme.textTheme.bodyMedium),
                ],
                const SizedBox(height: 16),

                // Description
                label('Description'),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Describe the issue',
                    filled: true,
                  ),
                  maxLines: 3,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Required'
                      : null,
                ),
                const SizedBox(height: 16),

                // Cost
                if (!isTenant) ...[
                  label('Cost'),
                  TextFormField(
                    controller: _costCtrl,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.attach_money),
                      hintText: '0.00',
                      filled: true,
                    ),
                    keyboardType: const TextInputType
                        .numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'Required';
                      final n = double.tryParse(v);
                      return (n == null || n < 0) ? 'Invalid' : null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Status & Payment
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          label('Status'),
                          DropdownButtonFormField<String>(
                            value: _status,
                            decoration:
                            const InputDecoration(filled: true),
                            items: const [
                              'Open',
                              'Scheduled',
                              'Tenant Verifying',
                              'Completed',
                            ]
                                .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s),
                            ))
                                .toList(),
                            onChanged: (v) {
                              if (v == null) return;
                              setState(() {
                                _status = v;
                                if (v == 'Scheduled') {
                                  _dateScheduled = null;
                                  _dateCompleted = null;
                                } else if (v == 'Completed') {
                                  _dateCompleted = DateTime.now();
                                  _dateScheduled = null;
                                } else {
                                  _dateScheduled = null;
                                  _dateCompleted = null;
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    if (!isTenant) const SizedBox(width: 16),
                    if (!isTenant)
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            label('Payment'),
                            DropdownButtonFormField<String>(
                              value: _paymentStatus,
                              decoration: const InputDecoration(
                                  filled: true),
                              items: const [
                                'Unpaid',
                                'Partly Paid',
                                'Paid'
                              ]
                                  .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(s),
                              ))
                                  .toList(),
                              onChanged: (!isOwner) ?null :  (v) {
                                if (v == null) return;
                                setState(() {
                                  _paymentStatus = v;
                                  if (v == 'Partly Paid') {
                                    _partialCtrl.text = '0.0';
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Partial Amount
                if (_paymentStatus == 'Partly Paid') ...[
                  label('Amount Paid'),
                  TextFormField(
                    controller: _partialCtrl,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.payments),
                      hintText: '0.00',
                      filled: true,
                    ),
                    keyboardType: const TextInputType
                        .numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'Required';
                      final n = double.tryParse(v);
                      return (n == null || n < 0)
                          ? 'Invalid'
                          : null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Scheduled Date Picker
                if (_status == 'Scheduled') ...[
                  label('Schedule Date'),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_dateScheduled == null
                        ? 'Pick a date'
                        : DateFormat.yMd()
                        .format(_dateScheduled!)),
                    trailing:
                    const Icon(Icons.calendar_today),
                    onTap: () => _pickDate(
                      initial:
                      _dateScheduled ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(
                          const Duration(days: 365)),
                      onPicked: (d) =>
                          setState(() => _dateScheduled = d),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Date Logged
                label('Date Logged'),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                      DateFormat.yMd().add_jm().format(_dateLogged)),
                  trailing:
                  const Icon(Icons.calendar_today),
                  onTap: () => _pickDate(
                    initial: _dateLogged,
                    firstDate: DateTime.now().subtract(
                        const Duration(days: 365)),
                    onPicked: (d) =>
                        setState(() => _dateLogged = d),
                  ),
                ),
                const SizedBox(height: 16),

                // Date Completed (read‐only when Completed)
                if (_status == 'Completed') ...[
                  label('Date Completed'),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      _dateCompleted == null
                          ? dateFmt.format(DateTime.now())
                          : dateFmt.format(_dateCompleted!),
                    ),
                    trailing:
                    const Icon(Icons.calendar_today),
                    enabled: false,
                  ),
                  const SizedBox(height: 24),
                ],

                // Contractor
                label('Contractor'),
                FutureBuilder<List<ContractorAndOwner>>(
                  future: _contractorsFuture,
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return const Center(
                          child:
                          CircularProgressIndicator());
                    }
                    final list = snap.data!;
                    return DropdownButtonFormField<String>(
                      value: _selectedContractorId,
                      decoration: const InputDecoration(
                          filled: true),
                      items: [
                        const DropdownMenuItem<String>(
                          value: '',
                          child: Text('Unassigned'),
                        ),
                        ...list.map((c) =>
                            DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            )),
                      ],
                      onChanged: (!isOwner) ? null
                          : (v) => setState(
                              () => _selectedContractorId = v),
                    );
                  },
                ),
                const SizedBox(height: 24),
                label('Property Mgr'),
                FutureBuilder<List<ContractorAndOwner>>(
                  future: _ownersFuture,
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return const Center(
                          child:
                          CircularProgressIndicator());
                    }
                    final list = snap.data!;
                    return DropdownButtonFormField<String>(
                      value: _selectedOwnerId,
                      decoration: const InputDecoration(
                          filled: true),
                      items: [
                        const DropdownMenuItem<String>(
                          value: '0',
                          child: Text('Unassigned'),
                        ),
                        ...list.map((c) =>
                            DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            )),
                      ],
                      onChanged: (!isOwner) ? null
                          : (v) => setState(
                              () => _selectedOwnerId = v),
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: _isSaving
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.save),
                    label: Text(widget.existingIssue ==
                        null
                        ? 'Create Issue'
                        : 'Update Issue'),
                    onPressed:
                    _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

