import 'package:flutter_test/flutter_test.dart';
import 'package:nkap_tracker/main.dart';

void main() {
  testWidgets('Nkap Tracker smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NkapTrackerApp());
  });
}