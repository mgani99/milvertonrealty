import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../model/repair_model.dart';

class SummaryTab extends StatefulWidget {
  final Stream<List<Issue>> stream;
  const SummaryTab({Key? key, required this.stream}) : super(key: key);

  @override
  State<SummaryTab> createState() => _SummaryTabState();
}

class _SummaryTabState extends State<SummaryTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return StreamBuilder<List<Issue>>(
      stream: widget.stream,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final issues = snap.data!;

        //── summary metrics ───────────────────────────────
        final totalIssues = issues.length;

        // completed count by owner
        final completedByOwner = _totalsBy<String>(
          issues,
              (i) => (i.ownerName?.isNotEmpty == true) ? i.ownerName! : 'Unassigned',
              (i) => i.status == 'Completed' ? 1.0 : 0.0,
        );

        // open count by owner
        final openByOwner = _totalsBy<String>(
          issues,
              (i) => (i.ownerName?.isNotEmpty == true) ? i.ownerName! : 'Unassigned',
              (i) => i.status != 'Completed' ? 1.0 : 0.0,
        );

        // prepare sorted DataRow list
        final owners = completedByOwner.keys.toList()..sort();
        final summaryRows = owners.map((owner) {
          final completed = completedByOwner[owner]?.toInt() ?? 0;
          final open = openByOwner[owner]?.toInt() ?? 0;
          return DataRow(cells: [
            DataCell(Text(owner)),
            DataCell(Text(completed.toString())),
            DataCell(Text(open.toString())),
          ]);
        }).toList();

        //── pie‐chart data ──────────────────────────────────
        final countByOwner = _totalsBy<String>(
          issues,
              (i) => (i.ownerName?.isNotEmpty == true) ? i.ownerName! : 'Unassigned',
              (_) => 1.0,
        );
        final countByContractor = _totalsBy<String>(
          issues,
              (i) =>
          (i.contractorName?.isNotEmpty == true) ? i.contractorName! : 'Unassigned',
              (_) => 1.0,
        );
        final countByStatus = _totalsBy<String>(
          issues,
              (i) => i.status,
              (_) => 1.0,
        );

        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              // ── Summary Table ──────────────────────────────
              Text('Summary', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Total Issues/Tasks: $totalIssues',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              DataTable(
                columns: const [
                  DataColumn(label: Text('Owner')),
                  DataColumn(label: Text('Completed')),
                  DataColumn(label: Text('Open')),
                ],
                rows: summaryRows,
              ),

              const SizedBox(height: 24),

              // ── Pie chart: % issues by owner ───────────────
              Text('Percentage of issues by owner',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SizedBox(
                height: 220,
                child: _pieChart(countByOwner, showPercentage: true),
              ),

              const SizedBox(height: 24),

              // ── Pie chart: % issues by contractor ──────────
              Text('Percentage of issues by contractor',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SizedBox(
                height: 220,
                child: _pieChart(countByContractor, showPercentage: true),
              ),

              const SizedBox(height: 24),

              // ── Pie chart: % issues by status ──────────────
              Text('Percentage of issues by status',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SizedBox(
                height: 220,
                child: _pieChart(countByStatus, showPercentage: true),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Generic aggregator: sums `valueSelector` per group `keySelector`.
  Map<K, double> _totalsBy<K>(
      List<Issue> items,
      K Function(Issue) keySelector,
      double Function(Issue) valueSelector,
      ) {
    final map = <K, double>{};
    for (final issue in items) {
      final key = keySelector(issue);
      map[key] = (map[key] ?? 0) + valueSelector(issue);
    }
    return map;
  }

  /// Renders a pie chart of `data`.
  /// If [showPercentage] is true, each slice shows:
  ///   line 1: name
  ///   line 2: percent of total
  Widget _pieChart(Map<String, double> data, {bool showPercentage = false}) {
    final entries = data.entries.toList();
    final total = entries.fold<double>(0, (sum, e) => sum + e.value);
    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.cyan,
      Colors.teal,
      Colors.amber,
    ];

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 0,
        sections: List.generate(entries.length, (i) {
          final entry = entries[i];
          final name = entry.key;
          final value = entry.value;
          final pct = total > 0 ? (value / total * 100) : 0;
          final title = showPercentage
              ? '$name\n${pct.toStringAsFixed(0)}%'
              : '$name\n${value.toInt()}';

          return PieChartSectionData(
            color: colors[i % colors.length],
            value: value,
            title: title,
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          );
        }),
      ),
    );
  }
}
