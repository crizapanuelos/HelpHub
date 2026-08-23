import 'package:flutter_test/flutter_test.dart';

import 'package:helphub/main.dart';

void main() {
  testWidgets('HelpHub starter screen renders correctly',
      (WidgetTester tester) async {
    // Build the actual HelpHub root application widget.
    await tester.pumpWidget(const HelpHubApp());

    // Verify that the expected HelpHub screen structure is displayed.
    expect(find.byType(HelpHubHomePage), findsOneWidget);
    expect(find.text('HelpHub'), findsOneWidget);
    expect(find.textContaining('HelpHub project is ready.'), findsOneWidget);
  });
}
