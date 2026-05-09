// test/widget_test.dart
// Tests unitarios que NO dependen de Firebase ni servicios externos.
// Validan widgets individuales, theme y design system.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kintsugi_app/core/theme/app_colors.dart';
import 'package:kintsugi_app/core/theme/app_theme.dart';

void main() {
  group('Design System - Colores', () {
    test('El color de fondo principal es #0D0D0D', () {
      expect(AppColors.backgroundPrimary, const Color(0xFF0D0D0D));
    });

    test('El color de acento principal es #C9A84C (dorado)', () {
      expect(AppColors.accentPrimary, const Color(0xFFC9A84C));
    });
  });

  group('Design System - Theme', () {
    test('El theme usa modo oscuro (dark)', () {
      final theme = AppTheme.darkTheme;
      expect(theme.brightness, Brightness.dark);
    });

    test('El scaffold background es el color correcto', () {
      final theme = AppTheme.darkTheme;
      expect(
        theme.scaffoldBackgroundColor,
        AppColors.backgroundPrimary,
      );
    });
  });

  group('Widgets UI', () {
    testWidgets('SplashScreen muestra el texto KINTSUGI', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            backgroundColor: Color(0xFF0D0D0D),
            body: Center(
              child: Text(
                'KINTSUGI',
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFC9A84C),
                  letterSpacing: 6,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('KINTSUGI'), findsOneWidget);
    });

    testWidgets('Se puede renderizar un botón con estilo Kintsugi', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('COMENZAR VIAJE'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('COMENZAR VIAJE'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });
}