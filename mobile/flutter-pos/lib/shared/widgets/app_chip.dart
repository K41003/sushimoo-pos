import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppChip extends StatelessWidget {
  final String label;
  final Color? color;
  final VoidCallback? onTap;
  final bool selected;

  const AppChip({
    super.key,
    required this.label,
    this.color,
    this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9999),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected
              ? (color ?? scheme.primary)
              : (color ?? scheme.surfaceContainerHigh).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? scheme.onPrimary : scheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Status pill used for order / table states.
class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip({super.key, required this.status});

  Color _color(BuildContext context) {
    switch (status) {
      case 'paid':
      case 'available':
        return const Color(0xFFA8DADC);
      case 'pending':
      case 'occupied':
      case 'open':
        return Colors.orange.shade300;
      case 'cancelled':
      case 'closed':
        return Colors.red.shade300;
      default:
        return Theme.of(context).colorScheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppChip(label: status.toUpperCase(), color: _color(context));
  }
}
