import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class BottomNavbar extends StatelessWidget {
  const BottomNavbar({
    super.key,
    this.currentIndex = 0,
    this.onHomeTap,
    this.onLibraryTap,
    this.onAddTap,
    this.onSearchTap,
    this.onProfileTap,
  });

  final int currentIndex;
  final VoidCallback? onHomeTap;
  final VoidCallback? onLibraryTap;
  final VoidCallback? onAddTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.text.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, -6),
          ),
        ],
        border: Border(
          top: BorderSide(color: AppColors.outline.withValues(alpha: 0.4), width: 1),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavItem(
            icon: Icons.home_outlined,
            label: 'Home',
            active: currentIndex == 0,
            onTap: onHomeTap,
          ),
          _NavItem(
            icon: Icons.bookmark_border_rounded,
            label: 'Library',
            active: currentIndex == 1,
            onTap: onLibraryTap,
          ),
          _AddButton(onTap: onAddTap ?? () {}),
          _NavItem(
            icon: Icons.search_rounded,
            label: 'Search',
            active: currentIndex == 3,
            onTap: onSearchTap,
          ),
          _NavItem(
            icon: Icons.person_outline_rounded,
            label: 'Profile',
            active: currentIndex == 4,
            onTap: onProfileTap,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = active
        ? AppColors.primary
        : AppColors.coffee.withValues(alpha: 0.6);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 3),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontSize: 11,
              fontWeight: active ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add, size: 26, color: AppColors.white),
      ),
    );
  }
}
