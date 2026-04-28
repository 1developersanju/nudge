import 'package:flutter/material.dart';

import '../data/repository.dart';
import '../theme/review_spacing_controller.dart';
import '../theme/theme_controller.dart';
import 'app_theme.dart';
import 'custom_revisit_spacing_dialog.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.repo,
    required this.theme,
    required this.spacing,
  });

  final LearningRepository repo;
  final ThemeController theme;
  final ReviewSpacingController spacing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          children: [
            // Header
            Text(
              'Settings',
              style: TextStyle(
                color: AppTheme.primaryContainer(context),
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'Control Center',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary(context),
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Personalize Nudge. Your preferences, like your data, remain local and private.',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.muted(context),
                height: 1.5,
              ),
            ),

            const SizedBox(height: 48),

            // Appearance
            _SectionTitle(title: 'APPEARANCE'),
            ListenableBuilder(
              listenable: theme,
              builder: (context, _) {
                return Row(
                  children: [
                    _ThemeOption(
                      icon: Icons.dark_mode,
                      title: 'Dark',
                      subtitle: 'Obsidian Night',
                      isSelected: theme.themeMode == ThemeMode.dark,
                      onTap: () => theme.setThemeMode(ThemeMode.dark),
                    ),
                    const SizedBox(width: 8),
                    _ThemeOption(
                      icon: Icons.light_mode,
                      title: 'Light',
                      subtitle: 'Paper White',
                      isSelected: theme.themeMode == ThemeMode.light,
                      onTap: () => theme.setThemeMode(ThemeMode.light),
                    ),
                    const SizedBox(width: 8),
                    _ThemeOption(
                      icon: Icons.settings_brightness,
                      title: 'System',
                      subtitle: 'Auto Shift',
                      isSelected: theme.themeMode == ThemeMode.system,
                      onTap: () => theme.setThemeMode(ThemeMode.system),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 40),

            // Review Spacing
            _SectionTitle(title: 'REVIEW SPACING'),
            ListenableBuilder(
              listenable: spacing,
              builder: (context, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLow(context),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          _SpacingOption(
                            label: 'Standard',
                            isSelected: spacing.presetId == 'production',
                            onTap: () async {
                              await spacing.setPreset('production');
                              await repo.rescheduleNotificationAlarms();
                            },
                          ),
                          _SpacingOption(
                            label: 'Test',
                            isSelected: spacing.presetId == 'test',
                            onTap: () async {
                              await spacing.setPreset('test');
                              await repo.rescheduleNotificationAlarms();
                            },
                          ),
                          _SpacingOption(
                            label: 'Custom',
                            isSelected: spacing.presetId == 'custom',
                            onTap: () async {
                              final initial =
                                  spacing.customMinutes ?? [1440, 10080, 43200];
                              final result =
                                  await showCustomRevisitSpacingDialog(
                                    context,
                                    initialMinutes: initial,
                                  );
                              if (result != null && context.mounted) {
                                await spacing.setCustomMinutes(result);
                                await repo.rescheduleNotificationAlarms();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      spacing.profile.aboutSettingsSubtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.muted(context).withValues(alpha: 0.8),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 40),

            // Data & Privacy
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerHigh(context),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Data & Privacy',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your intellectual capital is yours alone. We do not use cloud sync or AI training models.',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppTheme.muted(context),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary(context).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          color: AppTheme.primary(context),
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'STORED ONLY ON THIS DEVICE',
                          style: TextStyle(
                            color: AppTheme.primary(context),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Danger Zone
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Danger Zone',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Clearing all data is irreversible. All notes, streaks, and progress will be permanently deleted from this device.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.muted(context),
                    ),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: BorderSide(
                        color: Colors.redAccent.withValues(alpha: 0.3),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    onPressed: () async {
                      await repo.clearAll();
                    },
                    child: const Text(
                      'Clear all data',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100), // BottomNav padding
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
          color: AppTheme.muted(context),
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.surfaceContainerHigh(context)
                : AppTheme.surfaceContainerLow(context),
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(color: AppTheme.primary(context), width: 2)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppTheme.primary(context)
                    : AppTheme.muted(context),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: AppTheme.muted(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpacingOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SpacingOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.surfaceContainerHigh(context)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    const BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? AppTheme.primary(context)
                  : AppTheme.muted(context),
            ),
          ),
        ),
      ),
    );
  }
}
