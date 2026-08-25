import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../app/constants/colors.dart';
import '../../app/constants/dimensions.dart';
import 'glass_panel.dart';

/// Generic data table built on Flutter's Table with horizontal scroll,
/// presented inside a frosted glass panel card.
class AppDataTable extends StatelessWidget {
  final List<String> columns;
  final List<List<Widget>> rows;

  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: AppDimensions.radiusLg,
      padding: EdgeInsets.zero,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          border: const TableBorder.symmetric(
            inside: BorderSide(color: AppColors.hairline),
          ),
          columnWidths: {
            for (var i = 0; i < columns.length; i++)
              i: const IntrinsicColumnWidth(),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.35),
              ),
              children: columns
                  .map((c) => Padding(
                        padding: EdgeInsets.all(14.r),
                        child: Text(
                          c,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.ink,
                              ),
                        ),
                      ))
                  .toList(),
            ),
            ...rows.map(
              (row) => TableRow(
                children: row
                    .map((cell) => Padding(
                          padding: EdgeInsets.all(14.r),
                          child: cell,
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

