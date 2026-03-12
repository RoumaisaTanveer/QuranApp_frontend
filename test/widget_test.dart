import 'package:flutter_test/flutter_test.dart';
import 'package:quran_journal/main.dart';

void main() {
  testWidgets('App loads', (WidgetTester tester) async {
    await tester.pumpWidget(const QuranJournalApp());
    expect(find.text('مع القرآن'), findsOneWidget);
  });
}
