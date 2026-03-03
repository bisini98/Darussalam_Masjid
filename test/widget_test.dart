import 'package:darussalam_masjid/main.dart';
import 'package:darussalam_masjid/providers/app_providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('App launches and shows Dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppProvider()..seedSampleData(),
        child: const MasjidApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Dashboard should be visible by default
    expect(find.text('Dashboard'), findsWidgets);
  });
}
