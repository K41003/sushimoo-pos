import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/constants/colors.dart';
import '../../../app/constants/dimensions.dart';
import '../../../data/models/table.dart' as tm;
import '../../../shared/widgets/glass_panel.dart';

/// A single tappable table card used inside [TableSelectSheet].
///
/// REPLACES the old inline `ChoiceChip` used for table selection — a
/// chip is meant for filters/tags, not for a primary "pick one physical
/// table" action on a POS. This card gives each table its own visual
/// weight (icon, big number, seat count) and a clear pressed/selected
/// state, matching the same interaction language as `PosProductTile`
/// and `AppButton` elsewhere in the app.
class _TableCard extends StatefulWidget {
  final tm.TableModel table;
  final bool selected;
  final VoidCallback onTap;

  const _TableCard({
    required this.table,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_TableCard> createState() => _TableCardState();
}

class _TableCardState extends State<_TableCard> {
  bool _pressed = false;

  Color _statusColor(String status) {
    switch (status) {
      case 'available':
        return AppColors.emerald;
      case 'occupied':
        return AppColors.warning;
      case 'reserved':
        return const Color(0xFF2F6FED);
      case 'cleaning':
        return AppColors.inkFaint;
      default:
        return AppColors.inkFaint;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final statusColor = _statusColor(widget.table.status);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
          decoration: BoxDecoration(
            gradient: selected ? AppColors.salmonGradient : null,
            color: selected ? null : Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
            border: Border.all(
              color: selected ? Colors.transparent : AppColors.glassBorder(opacity: 0.7),
              width: 1.4,
            ),
            boxShadow: selected ? AppColors.shadowSalmon : null,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.table_restaurant_rounded,
                      size: 26.sp,
                      color: selected ? Colors.white : AppColors.inkFaint,
                    ),
                    Positioned(
                      top: -2,
                      right: -4,
                      child: Container(
                        width: 8.r,
                        height: 8.r,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? AppColors.salmon : Colors.white,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.table.nomorMeja,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.white : AppColors.ink,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${widget.table.kapasitas} kursi',
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white.withValues(alpha: 0.9) : AppColors.inkFaint,
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

/// Redesigned "Select Table" surface — REPLACES the plain `AlertDialog` +
/// `ChoiceChip` `Wrap` that used to live inline inside
/// `PosController.selectTable()`.
///
/// Kept as a standalone widget (rather than inline dialog content) so it
/// can be reused/tested independently and so the character of the app
/// (glass surface, salmon gradient selection, status dots) shows up
/// consistently here too, instead of falling back to stock Material
/// dialog styling.
///
/// Usage: `Get.dialog<tm.TableModel>(TableSelectSheet(tables: ..., selectedId: ...))`
/// — returns the picked [tm.TableModel] via `Get.back(result: ...)`,
/// same contract as the old dialog so `PosController.selectTable()` only
/// needs its dialog-building call site swapped, not its logic.
class TableSelectSheet extends StatelessWidget {
  final List<tm.TableModel> tables;
  final int? selectedId;

  const TableSelectSheet({
    super.key,
    required this.tables,
    required this.selectedId,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 460.w, maxHeight: 520.h),
        child: GlassPanel(
          radius: AppDimensions.radiusXl,
          strong: true,
          padding: EdgeInsets.all(AppDimensions.lg.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pilih Meja', style: Theme.of(context).textTheme.headlineMedium),
                        SizedBox(height: 2.h),
                        Text(
                          'Ketuk meja untuk menetapkan pesanan ini',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, size: 20.sp, color: AppColors.inkFaint),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.md.h),
              if (tables.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: AppDimensions.xl.h),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.table_bar_outlined, size: 36.sp, color: AppColors.inkFaint),
                        SizedBox(height: 10.h),
                        Text('Belum ada meja tersedia', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                )
              else
                Flexible(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Adapts to the dialog's actual available width
                      // instead of a flat 4 columns — on a narrow phone
                      // (where this dialog's ConstrainedBox itself
                      // shrinks to fit the screen) 4 fixed columns made
                      // each table card too cramped to tap comfortably.
                      final cols = constraints.maxWidth >= 420
                          ? 4
                          : (constraints.maxWidth >= 280 ? 3 : 2);
                      return GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          crossAxisSpacing: 10.w,
                          mainAxisSpacing: 10.h,
                          childAspectRatio: 0.78,
                        ),
                        itemCount: tables.length,
                        itemBuilder: (_, i) {
                          final t = tables[i];
                          return _TableCard(
                            table: t,
                            selected: t.idMeja == selectedId,
                            onTap: () => Get.back(result: t),
                          );
                        },
                      );
                    },
                  ),
                ),
              SizedBox(height: AppDimensions.sm.h),
              Wrap(
                spacing: 14.w,
                runSpacing: 6.h,
                children: [
                  _legendDot(context, AppColors.emerald, 'Tersedia'),
                  _legendDot(context, AppColors.warning, 'Terpakai'),
                  _legendDot(context, const Color(0xFF2F6FED), 'Dipesan'),
                  _legendDot(context, AppColors.inkFaint, 'Dibersihkan'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legendDot(BuildContext context, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7.r,
          height: 7.r,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 5.w),
        Text(label, style: TextStyle(fontSize: 10.5.sp, color: AppColors.inkFaint, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
