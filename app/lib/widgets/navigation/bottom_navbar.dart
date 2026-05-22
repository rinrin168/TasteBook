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
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
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
        ? AppColors.coffee
        : AppColors.text.withValues(alpha: 0.85);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 1),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontSize: 17,
              fontWeight: FontWeight.w600,
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
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white,
          border: Border.all(
            color: AppColors.text.withValues(alpha: 0.72),
            width: 2.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.add, size: 34, color: AppColors.text),
      ),
    );
  }
}
