import 'package:flutter_test/flutter_test.dart';

import 'package:kintsugi_app/main.dart';

void main() {
  testWidgets('La app arranca sin errores', (WidgetTester tester) async {
    // Verifica que KintsugiApp se renderiza sin lanzar excepciones
    await tester.pumpWidget(const KintsugiApp());
    expect(find.byType(KintsugiApp), findsOneWidget);
  });
}
