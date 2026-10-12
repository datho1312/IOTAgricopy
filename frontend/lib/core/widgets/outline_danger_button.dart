// lib/core/widgets/outline_danger_button.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A reusable outlined button styled for "danger" actions (red color).
class OutlineDangerButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color color;
  final String? semanticsLabel;
  final double iconSize;
  final bool iconOnly;

  const OutlineDangerButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.color = AppColors.danger,
    this.semanticsLabel,
    this.iconSize = 20,
    this.iconOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel ?? label,
      button: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final style = OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          );
          final iconWidget = Icon(
            icon ?? Icons.logout,
            color: color,
            size: iconSize,
          );
          return SizedBox(
            width: constraints.hasBoundedWidth ? double.infinity : null,
            child: iconOnly
                ? OutlinedButton(
                    onPressed: onPressed,
                    style: style,
                    child: iconWidget,
                  )
                : OutlinedButton.icon(
                    onPressed: onPressed,
                    icon: iconWidget,
                    label: Text(label),
                    style: style,
                  ),
          );
        },
      ),
    );
  }
}
