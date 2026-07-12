import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Generic data table built on Flutter's Table with horizontal scroll.
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        columnWidths: {
          for (var i = 0; i < columns.length; i++)
            i: const IntrinsicColumnWidth(),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
            ),
            children: columns
                .map((c) => Padding(
                      padding: EdgeInsets.all(12.r),
                      child: Text(c,
                          style: Theme.of(context).textTheme.labelLarge),
                    ))
                .toList(),
          ),
          ...rows.map(
            (row) => TableRow(
              children: row
                  .map((cell) => Padding(
                        padding: EdgeInsets.all(12.r),
                        child: cell,
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
