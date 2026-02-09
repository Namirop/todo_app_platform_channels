import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:todoapp/main.dart';

void main() {
  testWidgets('App loads login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: TodoApp()));

    await tester.pumpAndSettle();

    // Verify login screen is displayed
    expect(find.text('Todo App'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
  });
}
