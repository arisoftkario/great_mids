import 'package:flutter_test/flutter_test.dart';

import 'package:great_minds/main.dart';

void main() {
  testWidgets('Great Minds Group landing page renders its main content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GreatMindsApp());

    expect(find.text('GREAT MINDS\nGROUP'), findsOneWidget);
    expect(find.bySemanticsLabel('Logo GREAT MINDS GROUP'), findsOneWidget);
    expect(find.text('NOS SERVICES'), findsOneWidget);
    expect(find.text('NOS UNIVERS'), findsOneWidget);
    expect(find.text('Parfums d’exception'), findsOneWidget);
    expect(find.text('GM Texa — Visa & passeport'), findsOneWidget);
    expect(find.text('GM Autosolution'), findsOneWidget);
    expect(find.text('GM Fondation'), findsOneWidget);
    expect(find.text('Visiter le département'), findsNWidgets(4));
    expect(find.text('Passer commande'), findsOneWidget);
    expect(find.text('Faire une demande'), findsOneWidget);
    expect(find.text('Demander un devis'), findsOneWidget);
    expect(find.text('Nous rejoindre'), findsOneWidget);
    expect(find.text('Écrire sur WhatsApp'), findsOneWidget);
    expect(find.text('WhatsApp : +243 994 673 769'), findsOneWidget);
  });

  testWidgets('department visit displays department offerings', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GreatMindsApp());

    await tester.tap(find.text('Visiter le département').first);
    await tester.pumpAndSettle();

    expect(find.text('L’univers GM Parfum'), findsOneWidget);
    expect(find.text('Parfums signature'), findsOneWidget);
    expect(find.text('Coffrets cadeaux'), findsOneWidget);
    expect(find.text('Commande accompagnée'), findsOneWidget);
  });
}
