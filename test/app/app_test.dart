import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:podo/app/app.dart';

void main() {
  testWidgets('PoDoApp builds and provides FTheme', (WidgetTester tester) async {
    await tester.pumpWidget(const PoDoApp());
    await tester.pumpAndSettle();

    expect(find.byType(FTheme), findsWidgets);
  });
}
