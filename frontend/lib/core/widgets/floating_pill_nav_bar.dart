// lib/core/widgets/floating_pill_nav_bar.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A floating bottom navigation bar with a pill‑shaped background for the selected
/// tab. It mirrors the design described in Phase 3.
class FloatingPillNavBar extends StatelessWidget {
  const FloatingPillNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final void Function(int) onTap;

  static const _icons = [
    Icons.home_outlined,
    Icons.spa_outlined,
    Icons.tune_outlined,
    Icons.grid_view_outlined,
  ];

  static const _labels = ['Trang chủ', 'Chọn Giống', 'Điều khiển', 'Khác'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withValues(alpha: 0.48)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.forestGreen.withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: List.generate(_icons.length, (index) {
                  final selected = index == currentIndex;
                  final foreground = selected
                      ? Colors.white
                      : AppColors.forestGreen;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: InkWell(
                        onTap: () => onTap(index),
                        borderRadius: BorderRadius.circular(22),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.forestGreen
                                : Colors.white.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: selected
                                  ? AppColors.forestGreen
                                  : AppColors.forestGreen.withValues(
                                      alpha: 0.7,
                                    ),
                              width: 1.25,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_icons[index], color: foreground, size: 24),
                              const SizedBox(height: 4),
                              Text(
                                _labels[index],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: foreground,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
