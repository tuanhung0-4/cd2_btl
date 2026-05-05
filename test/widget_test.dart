import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_canvas/main.dart';

void main() {
  testWidgets('Kiem tra giao dien Login', (WidgetTester tester) async {
    // Build app
    await tester.pumpWidget(const MyApp());

    // Kiem tra xem co chu WELCOME tren man hinh khong
    expect(find.text('WELCOME'), findsOneWidget);

    // Kiem tra xem co nut Login khong
    expect(find.text('Login'), findsWidgets);
  });
}