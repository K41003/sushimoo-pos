import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../app/constants/colors.dart';

/// REPLACES the old flat `AppTextField` 1:1 (same constructor: `label`,
/// `hint`, `controller`, `obscure`, `keyboardType`, `validator`,
/// `onChanged`, `maxLines`), so every existing call site keeps compiling.
/// Visual layer now uses a frosted-glass fill with a border that
/// brightens to the salmon accent on focus.
class AppTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscure;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int maxLines;
  final bool dense;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.dense = false,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() => _focused = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null)
          Padding(
            padding: EdgeInsets.only(bottom: 8.h, left: 2.w),
            child: Text(
              widget.label!,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
                color: AppColors.inkMuted,
              ),
            ),
          ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: _focused ? AppColors.salmon : AppColors.glassBorder(opacity: 0.7),
              width: _focused ? 1.6 : 1.2,
            ),
            boxShadow: _focused ? AppColors.shadowSm : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscure,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            onChanged: widget.onChanged,
            maxLines: widget.maxLines,
            style: TextStyle(
              fontSize: 16.5.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.ink,
            ),
            decoration: InputDecoration(
              isDense: widget.dense,
              hintText: widget.hint,
              hintStyle: TextStyle(
                fontSize: 15.sp,
                color: AppColors.inkFaint,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.suffixIcon,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: widget.dense ? 10.h : 14.h,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Compact glassmorphic search input field designed specifically for
/// header action bars and compact toolbars.
/// Fixed 36px height with perfect vertical centering, search icon prefix,
/// clear button, and focus styling.
class AppHeaderSearchField extends StatefulWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final double? width;
  final TextEditingController? controller;

  const AppHeaderSearchField({
    super.key,
    this.hint = 'Cari...',
    this.onChanged,
    this.onClear,
    this.width,
    this.controller,
  });

  @override
  State<AppHeaderSearchField> createState() => _AppHeaderSearchFieldState();
}

class _AppHeaderSearchFieldState extends State<AppHeaderSearchField> {
  late final TextEditingController _controller;
  late final bool _internalController;
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(() => setState(() => _focused = _focusNode.hasFocus));
  }

  void _onTextChanged() {
    final has = _controller.text.isNotEmpty;
    if (has != _hasText) {
      setState(() => _hasText = has);
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.removeListener(_onTextChanged);
    if (_internalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleClear() {
    _controller.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      // Same reasoning as the constraints change above: allow this
      // field to shrink down to a usable minimum instead of forcing a
      // flat width and pushing a sibling '+' action button off-screen
      // on narrow phones.
      constraints: BoxConstraints(
        minWidth: 100,
        maxWidth: widget.width ?? 180.w,
      ),
      child: Container(
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _focused ? AppColors.salmon : AppColors.glassBorder(opacity: 0.7),
            width: _focused ? 1.4 : 1.0,
          ),
          boxShadow: _focused ? AppColors.shadowSm : null,
        ),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: widget.onChanged,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.ink,
          ),
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            isDense: true,
            hintText: widget.hint,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: AppColors.inkFaint,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              size: 18.sp,
              color: _focused ? AppColors.salmon : AppColors.inkMuted,
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 36),
            suffixIcon: _hasText
                ? IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 36),
                    icon: Icon(Icons.close_rounded, size: 16.sp, color: AppColors.inkMuted),
                    onPressed: _handleClear,
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(minWidth: 28, minHeight: 36),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          ),
        ),
      ),
    );
  }
}
