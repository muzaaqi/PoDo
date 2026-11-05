import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:podo/core/theme/app_theme.dart';
import 'package:podo/core/widgets/stat_card.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return FTheme(
      data: AppTheme.lightTheme,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: const MediaQueryData(),
          child: child,
        ),
      ),
    );
  }

  testWidgets('StatCard renders title, value, icon, and uses FCard', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        const StatCard(
          title: 'Total SKS',
          value: '6 SKS',
          icon: FLucideIcons.bookOpen,
        ),
      ),
    );

    expect(find.byType(FCard), findsOneWidget);
    expect(find.text('Total SKS'), findsOneWidget);
    expect(find.text('6 SKS'), findsOneWidget);
    expect(find.byIcon(FLucideIcons.bookOpen), findsOneWidget);
  });
}
