import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/styling/app_text_styles.dart';
import '../../../tasks/data/repo/platforms_repository.dart';
import '../../../tasks/data/repo/task_types_repository.dart';
import '../../../workspace/presentation/widgets/app_sidebar.dart';
import '../widgets/lookup_list_editor.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskTypesRepo = context.read<TaskTypesRepository>();
    final platformsRepo = context.read<PlatformsRepository>();

    return Scaffold(
      body: Row(
        children: [
          const AppSidebar(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.arrowLeft),
                        onPressed: () => context.go(Routes.workspaceKanban),
                      ),
                      const SizedBox(width: 8),
                      Text('Settings', style: AppTextStyles.h1),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Workspace lists',
                            style: AppTextStyles.body
                                .copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: 12),
                        LookupListEditor(
                          title: 'Task Types',
                          icon: LucideIcons.tag,
                          load: () async => (await taskTypesRepo.getTypes())
                              .map((t) => LookupItem(t.taskType, t.title))
                              .toList(),
                          rename: taskTypesRepo.renameType,
                          create: taskTypesRepo.createType,
                          delete: taskTypesRepo.deleteType,
                        ),
                        const SizedBox(height: 16),
                        LookupListEditor(
                          title: 'Platforms',
                          icon: LucideIcons.share2,
                          load: () async => (await platformsRepo.getPlatforms())
                              .map((p) => LookupItem(p.platform, p.title))
                              .toList(),
                          rename: platformsRepo.renamePlatform,
                          create: platformsRepo.createPlatform,
                          delete: platformsRepo.deletePlatform,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
