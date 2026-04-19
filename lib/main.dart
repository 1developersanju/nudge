import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'background/review_background.dart';
import 'background/review_time_zone.dart';
import 'data/repository.dart';
import 'theme/review_spacing_controller.dart';
import 'theme/theme_controller.dart';
import 'ui/app_theme.dart';
import 'ui/root_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await configureReviewTimeZone();
  } catch (e, st) {
    if (kDebugMode) {
      debugPrint('configureReviewTimeZone skipped: $e\n$st');
    }
  }
  try {
    await configureLocalNotifications();
    await registerReviewBackgroundWork();
  } catch (e, st) {
    if (kDebugMode) {
      debugPrint('Background work init skipped: $e\n$st');
    }
  }

  final spacing = ReviewSpacingController();
  final repo = LearningRepository(spacing: spacing);
  final theme = ThemeController();
  await Future.wait([spacing.load(), repo.load(), theme.load()]);
  runApp(LogNReviewApp(repo: repo, theme: theme, spacing: spacing));
}

class LogNReviewApp extends StatelessWidget {
  const LogNReviewApp({
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
    return ListenableBuilder(
      listenable: Listenable.merge([theme, spacing]),
      builder: (context, _) {
        return MaterialApp(
          title: 'Nudge',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: theme.themeMode,
          home: RootScreen(repo: repo, theme: theme, spacing: spacing),
        );
      },
    );
  }
}
