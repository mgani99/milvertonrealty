import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/repair_model.dart';

class IssueCard extends StatelessWidget {
  final Issue issue;
  final VoidCallback? onTap;

  const IssueCard({
    Key? key,
    required this.issue,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme      = Theme.of(context);
    final colors     = theme.colorScheme;
    final surface    = colors.surface;
    final onSurface  = colors.onSurface;

    final statusColor   = _statusColor(issue.status);
    final paymentColor  = _paymentColor(issue.paymentStatus);
    final costText      = NumberFormat.simpleCurrency().format(issue.cost);
    final mgrInitials   = _initials(issue.ownerName ?? '');
    final dateFmt       = DateFormat.yMd();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Stack(
          children: [
            // ─── Main Content ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Unit + Manager Badge
                  Row(
                    children: [
                      Text(
                        'Unit: ${issue.unit}',
                        style: theme.textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),

                      const Spacer(),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Description
                  Text(
                    issue.description,
                    style: theme.textTheme.bodyMedium!
                        .copyWith(color: onSurface.withOpacity(0.8)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 16),

                  // Footer: Contractor | Cost + Payment Status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.engineering,
                        size: 20,
                        color: onSurface.withOpacity(0.7),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          issue.contractorName,
                          style: theme.textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Cost above Payment status

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            costText,
                            style: theme.textTheme.bodyMedium!
                                .copyWith(
                              color: colors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            issue.paymentStatus,
                            style: theme.textTheme.bodySmall!
                                .copyWith(
                              color: paymentColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ─── Status Badge with Date ────────────────────────────
            Positioned(
              top: 12,
              right: 10,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start, // ensures top alignment
                  children: [
                    if (mgrInitials.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Align(
                        alignment: Alignment.topCenter,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: (mgrInitials != 'U') ? colors.primary : colors.error,
                          child: Text(
                            mgrInitials,
                            style: theme.textTheme.bodySmall!.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            issue.status,
                            style: theme.textTheme.bodySmall!.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (issue.status == 'Scheduled' && issue.scheduleDate != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.schedule, size: 12, color: statusColor),
                                const SizedBox(width: 3),
                                Text(
                                  dateFmt.format(issue.scheduleDate!),
                                  style: theme.textTheme.bodySmall!.copyWith(
                                    color: onSurface.withOpacity(0.75),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            )

          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.blue.shade600;
      case 'Scheduled':

        return Colors.green.shade600;
      case 'Tenant Verifying':
        return Colors.blueGrey;
      default:
        return Colors.grey.shade500;
    }
  }

  Color _paymentColor(String paymentStatus) {
    switch (paymentStatus) {
      case 'Paid':
        return Colors.green.shade400;
      case 'Partial Paid':
        return Colors.orange.shade400;
      case 'Unpaid':
        return Colors.red.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

  String _initials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return parts[0][0].toUpperCase() + parts[1][0].toUpperCase();
    }
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '';
  }
}
