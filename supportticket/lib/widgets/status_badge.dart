import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../theme/app_colors.dart';

/// Reusable status badge widget with modern design
class StatusBadge extends StatelessWidget {
  final TicketStatus status;
  final bool isLarge;

  const StatusBadge({
    super.key,
    required this.status,
    this.isLarge = false,
  });

  Color get _statusColor {
    switch (status) {
      case TicketStatus.open:
        return AppColors.statusOpen;
      case TicketStatus.inProgress:
        return AppColors.statusInProgress;
      case TicketStatus.closed:
        return AppColors.statusClosed;
    }
  }

  IconData get _statusIcon {
    switch (status) {
      case TicketStatus.open:
        return Icons.radio_button_unchecked;
      case TicketStatus.inProgress:
        return Icons.hourglass_empty;
      case TicketStatus.closed:
        return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = isLarge ? 16.0 : 12.0;
    final padding = isLarge
        ? const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 6);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isLarge ? 20 : 12),
        border: Border.all(color: _statusColor, width: isLarge ? 2 : 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon, color: _statusColor, size: size),
          const SizedBox(width: 8),
          Text(
            status.toString(),
            style: TextStyle(
              color: _statusColor,
              fontWeight: FontWeight.bold,
              fontSize: size,
            ),
          ),
        ],
      ),
    );
  }
}


