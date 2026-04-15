import 'package:flutter_test/flutter_test.dart';
import 'package:quan_li_cong_viec/main.dart';

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