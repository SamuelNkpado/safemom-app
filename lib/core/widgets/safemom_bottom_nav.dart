import 'package:flutter/material.dart';
import 'package:safemom/core/constants/app_colors.dart';
import 'package:safemom/core/theme/app_text_styles.dart';

class SafeMomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onSosPressed;

  const SafeMomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onSosPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 72,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _NavItem(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      isActive: currentIndex == 0,
                      onTap: () => onTabSelected(0),
                    ),
                    _NavItem(
                      icon: Icons.favorite_rounded,
                      label: 'Track',
                      isActive: currentIndex == 1,
                      onTap: () => onTabSelected(1),
                    ),
                    const SizedBox(width: 64),
                    _NavItem(
                      icon: Icons.forum_rounded,
                      label: 'Community',
                      isActive: currentIndex == 2,
                      onTap: () => onTabSelected(2),
                    ),
                    _NavItem(
                      icon: Icons.person_rounded,
                      label: 'Me',
                      isActive: currentIndex == 3,
                      onTap: () => onTabSelected(3),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -18,
              child: GestureDetector(
                onTap: onSosPressed,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.emergencyRed,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.emergencyRed.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'SOS',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.teal : Colors.grey;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.caption.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
