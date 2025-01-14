import 'package:flutter_test/flutter_test.dart';
import 'package:mina/app/app.dart';
import 'package:mina/counter/counter.dart';

void main() {
  group('App', () {
    testWidgets('renders CounterPage', (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(CounterPage), findsOneWidget);
    });
  });
}
