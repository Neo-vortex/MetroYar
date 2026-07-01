import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../shared/widgets/section_title.dart';
import '../cubit/theme_cubit.dart';
import '../widgets/theme_option_tile.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تنظیمات')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const SectionTitle(
            title: 'ظاهر برنامه',
            subtitle: 'حالت نمایش روشن، تیره یا پیروی از تنظیمات گوشی را انتخاب کنید.',
          ),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, mode) {
              final cubit = context.read<ThemeCubit>();
              return Row(
                children: [
                  ThemeOptionTile(
                    icon: Icons.light_mode_rounded,
                    label: 'روشن',
                    isSelected: mode == ThemeMode.light,
                    onTap: () => cubit.setThemeMode(ThemeMode.light),
                  ),
                  const SizedBox(width: 10),
                  ThemeOptionTile(
                    icon: Icons.dark_mode_rounded,
                    label: 'تیره',
                    isSelected: mode == ThemeMode.dark,
                    onTap: () => cubit.setThemeMode(ThemeMode.dark),
                  ),
                  const SizedBox(width: 10),
                  ThemeOptionTile(
                    icon: Icons.settings_suggest_rounded,
                    label: 'پیش‌فرض سیستم',
                    isSelected: mode == ThemeMode.system,
                    onTap: () => cubit.setThemeMode(ThemeMode.system),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionTitle(title: 'دربارهٔ برنامه'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('درباره MetroYar'),
              subtitle: const Text('نسخه، توضیحات و اطلاعات سازنده'),
              trailing: const Icon(Icons.chevron_left_rounded),
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.about),
            ),
          ),
        ],
      ),
    );
  }
}
