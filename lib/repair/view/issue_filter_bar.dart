
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:milvertonrealty/common/service.dart';
import 'package:milvertonrealty/home/controller/app_data.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../common/domain/user.dart';
import '../../components/combo_box.dart';
import '../../components/multi_select_dropdown.dart';
import '../../propertysetup/controller/propertyUnitController.dart';
import '../controller/repair_controller.dart';
import '../model/repair_model.dart';

/// A filter ribbon: tap to expand/collapse the filters panel.
class FilterBar extends StatefulWidget {

  final IssueFilters filters;
  final ValueChanged<IssueFilters> onChanged;
  final int index;
  final int issueCount;

  const FilterBar({
    super.key,
    required this.index,
    required this.filters,
    required this.onChanged,
    required this.issueCount,
  });

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  bool _expanded = false;
  late final Future<List<ContractorAndOwner>> _ownersFuture;
  int filterResultcount = 0;
  @override
  void initState() {
    super.initState();
    final ctrl = Provider.of<RepairController>(context, listen: false);
    _ownersFuture = ctrl.repo.fetchUsersByRole().then((byRole) => byRole['Owner'] ?? <ContractorAndOwner>[]);
  }


  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final ctrl = Provider.of<RepairController>(context, listen: true);
    final isTenant =
        appData.settings['role'].toString().toLowerCase() == 'tenant';
    final isOwner =
        appData.settings['role'].toString().toLowerCase() == 'owner';

    // Build unit list depending on role
    List<String> allUnits = [];
    if (isTenant) {
      allUnits.add(appData.settings['unitName']);
    } else {
      final controller = Provider.of<PropertySetupController>(context);
      allUnits = ['All', 'Building']
        ..addAll(controller.unitData.map((u) => u['unitName'] as String));
      // trigger the load once
      if (controller.unitData.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.getProperty();
        });
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ─── Ribbon Header ──────────────────────────────────────────────────
        Material(
          color: Colors.grey.shade200,
          child: InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 8),
                   Text(
                    "Filters (${widget.issueCount} Tasks)",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),

        // ─── Animated Filters Panel ───────────────────────────────────────
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _buildFilterCard(context, allUnits, appData.settings['role'].toString().toLowerCase()),
          crossFadeState: _expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }

  Widget _buildFilterCard(
      BuildContext context, List<String> allUnits, String role) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Center(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Unit filter
              if (role != 'tenant')
                SizedBox(
                  width: 240,
                  child: MultiSelectDropdown<String>(
                    title: 'Select Units',
                    items: allUnits,
                    initialSelectedValues: widget.filters.unitQueries,
                    itemLabel: (unit) => unit,
                    onSelectionChanged: (selectedUnits) {
                      widget.onChanged(
                        widget.filters.copyWith(unitQueries: selectedUnits),
                      );
                    },
                  ),
                ),
              if (role == 'owner' && widget.index!=1)
              SizedBox(

                width: 185,
                child: FutureBuilder<List<ContractorAndOwner>>(
                  future: _ownersFuture,
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return const Center(
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }
                    final list = snap.data!;
                    return DropdownButtonFormField<String>(
                      value: widget.filters.ownerId ?? '',
                      decoration:
                      const InputDecoration(labelText: 'Property Mgr.'),



                      items: [
                        const DropdownMenuItem<String> (
                          value: '',
                          child: Text('All'),
                        ),
                        const DropdownMenuItem<String>(
                          value: '0',
                          child: Text('Unassigned'),
                        ),


                        ...list.map((c)=>
                            DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            )),
                      ],

                      onChanged: (v) => widget.onChanged(
                        widget.filters.copyWith(ownerId: v),
                      ),
                    );
                  },
                ),
              ),
              // Status filter
              SizedBox(
                height: 55,
                width: 176,
                child: DropdownButtonFormField<String>(
                  value: widget.filters.status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: [
                    'All',
                    'Open',
                    'Scheduled',
                    'Tenant Verifying',
                    'Completed'
                  ]
                      .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s),
                  ))
                      .toList(),
                  onChanged: (v) => widget.onChanged(
                    widget.filters.copyWith(status: v),
                  ),
                ),
              ),

              // Payment filter
              if (role != 'tenant')
                SizedBox(
                  width: (role == 'tenant') ? double.maxFinite : 185,
                  child: DropdownButtonFormField<String>(
                    value: widget.filters.paymentStatus,
                    decoration:
                    const InputDecoration(labelText: 'Payment'),
                    items: [
                      'All',
                      'Unpaid',
                      'Partly Paid',
                      'Paid'
                    ]
                        .map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(s),
                    ))
                        .toList(),
                    onChanged: (v) => widget.onChanged(
                      widget.filters.copyWith(paymentStatus: v),
                    ),
                  ),
                ),

              // Owner filter


              // Date range filter
              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: Text(_rangeLabel(widget.filters)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    final now = DateTime.now();
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(now.year - 2),
                      lastDate: DateTime(now.year + 1),
                    );
                    if (range != null) {
                      widget.onChanged(
                        widget.filters.copyWith(
                          from: range.start,
                          to: range.end,
                        ),
                      );
                    }
                  },
                ),
              ),

              // Clear dates button
              if (widget.filters.from != null ||
                  widget.filters.to != null)
                TextButton(
                  child: const Text('Clear dates'),
                  onPressed: () {
                    print('Clear dates pressed');
                    widget.onChanged(widget.filters.copyWith(from: null, to: null));
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _rangeLabel(IssueFilters f) {
    if (f.from == null && f.to == null) return 'Date range';
    if (f.from != null && f.to == null) return 'From ${DateFormat.yMd().format(f.from!)}';
    if (f.from == null && f.to != null) return 'Until ${DateFormat.yMd().format(f.to!)}';
    return '${DateFormat.yMd().format(f.from!)} – ${DateFormat.yMd().format(f.to!)}';
  }

}

