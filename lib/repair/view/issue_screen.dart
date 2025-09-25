import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/repair_model.dart';
class IssueScreen extends StatefulWidget {
  final Issue issue;

  const IssueScreen({Key? key, required this.issue}) : super(key: key);

  @override
  State<IssueScreen> createState() => _IssueScreenState();
}

class _IssueScreenState extends State<IssueScreen> {
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _dateRow(String label, DateTime? date) {
    if (date == null) return const SizedBox.shrink();
    final formatted = DateFormat.yMMMd().format(date);
    return _infoRow(label, formatted);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Issue #${widget.issue.id}'),
        // actions: [
        //   Chip(
        //     label: Text(widget.issue.status),
        //     backgroundColor: widget.issue.status == 'Completed' ? Colors.green : Colors.orange,
        //   ),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Unit & Dates
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Unit: ${widget.issue.unit}', style: theme.textTheme.bodySmall),
                    const SizedBox(height: 8),
                    _dateRow('Logged', widget.issue.dateLogged),
                    _dateRow('Scheduled', widget.issue.scheduleDate),
                    _dateRow('Completed', widget.issue.dateCompleted),
                  ],
                ),
              ),
            ),

            // Description
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Description', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(widget.issue.description),
                  ],
                ),
              ),
            ),

            // Assignment
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Assignment', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    _infoRow('Contractor', widget.issue.contractorName),
                    _infoRow('Owner', widget.issue.ownerName),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.call),
                          label: const Text('Call Contractor'),
                          onPressed: () {}, // implement call
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.sms),
                          label: const Text('SMS Owner'),
                          onPressed: () {}, // implement SMS
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Financials
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Financials', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    _infoRow('Cost', '\$${widget.issue.cost.toStringAsFixed(2)}'),
                    _infoRow('Payment Status', widget.issue.paymentStatus),
                    if (widget.issue.paymentStatus == 'Pending' && widget.issue.partialAmount > 0)
                      _infoRow('Partial Paid', '\$${widget.issue.partialAmount.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ),

            // Tenant Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tenant Info', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    _infoRow('Tenant Name', widget.issue.tenantName),
                    _infoRow('Tenant ID', widget.issue.tenantId),
                  ],
                ),
              ),
            ),

            // Actions
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    onPressed: () {}, // navigate to edit screen
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Mark Completed'),
                    onPressed: () {}, // update status
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
