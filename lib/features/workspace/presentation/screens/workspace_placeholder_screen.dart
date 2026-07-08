import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/styling/app_text_styles.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';

/// Temporary landing target for the auth guard while the full Workspace
/// shell (sidebar, toolbar, view tabs) is built out. Replaced wholesale
/// once the StatefulShellRoute lands.
class WorkspacePlaceholderScreen extends StatelessWidget {
  const WorkspacePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Signed in', style: AppTextStyles.h2),
            const SizedBox(height: 8),
            BlocBuilder<AuthCubit, AuthCubitState>(
              builder: (context, state) => Text(
                state.profile?.displayName ?? '',
                style: AppTextStyles.body,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => context.read<AuthCubit>().signOut(),
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
