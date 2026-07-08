import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/styling/app_text_styles.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final profile = context.watch<AuthCubit>().state.profile;

    return Container(
      width: 224,
      decoration: const BoxDecoration(gradient: AppColors.sidebarGradient),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(LucideIcons.rocket,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text('Booost',
                      style: AppTextStyles.h3.copyWith(color: Colors.white)),
                ],
              ),
            ),
            _NavItem(
              icon: LucideIcons.layoutGrid,
              label: 'Workspace',
              selected: location.startsWith(Routes.workspace),
              onTap: () => context.go(Routes.workspaceKanban),
            ),
            _NavItem(
              icon: LucideIcons.settings,
              label: 'Settings',
              selected: location.startsWith(Routes.settings),
              onTap: () => context.go(Routes.settings),
            ),
            const Spacer(),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 1,
              color: Colors.white.withValues(alpha: 0.08),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      profile?.initials ?? '?',
                      style: AppTextStyles.label.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      profile?.displayName ?? '',
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Sign out',
                    icon: Icon(LucideIcons.logOut,
                        size: 18, color: Colors.white.withValues(alpha: 0.7)),
                    onPressed: () => context.read<AuthCubit>().signOut(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          decoration: BoxDecoration(
            gradient: selected ? AppColors.primaryGradient : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(icon,
                      size: 18,
                      color: selected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.6)),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: selected ? Colors.white : Colors.white.withValues(alpha: 0.75),
                      fontWeight: selected ? FontWeight.w600 : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
