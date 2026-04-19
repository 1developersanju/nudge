import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lognreview/data/repository.dart';
import 'package:lognreview/main.dart';
import 'package:lognreview/theme/review_spacing_controller.dart';
import 'package:lognreview/theme/theme_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('home renders capture prompt', (WidgetTester tester) async {
    final spacing = ReviewSpacingController();
    final repo = LearningRepository(spacing: spacing);
    final theme = ThemeController();
    await Future.wait([spacing.load(), repo.load(), theme.load()]);
    await tester.pumpWidget(
      LogNReviewApp(repo: repo, theme: theme, spacing: spacing),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('What did you learn'), findsOneWidget);
    expect(find.textContaining('Revise Today'), findsOneWidget);
  });
}
