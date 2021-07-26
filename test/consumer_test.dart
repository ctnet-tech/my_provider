import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:my_provider/index.dart';

const providerKey = 'SIMPLE_PROVIDER';
const valueString = 'HELLO';
const valueStringNext = 'GOOD BYE';
const valueStringNULL = 'NULL';

main() {
  testWidgets("Consumer: basic usage", (WidgetTester tester) async {
    Provider<String?>(providerKey: providerKey, value: valueString);

    var consumer = Consumer<String>(
        providerKey: providerKey,
        builder: (context, value) {
          return Text(value, textDirection: TextDirection.ltr);
        });

    // with initial value
    await tester.pumpWidget(consumer);
    var valueFinder = find.text(valueString);
    expect(valueFinder, findsOneWidget);
  });

  testWidgets("Consumer: update provider's value", (WidgetTester tester) async {
    var simpleProvider =
        Provider<String?>(providerKey: providerKey, value: valueString);

    var consumer = Consumer<String>(
        providerKey: providerKey,
        builder: (context, value) {
          return Text(value, textDirection: TextDirection.ltr);
        });

    // with initial value
    await tester.pumpWidget(consumer);

    // update provider's value
    simpleProvider.setValue(valueStringNext);
    await tester.pump();
    var valueFinder = find.text(valueStringNext);
    expect(valueFinder, findsOneWidget);
  });

  testWidgets("Provider: dispose", (WidgetTester tester) async {
    var simpleProvider =
        Provider<String?>(providerKey: providerKey, value: valueString);

    var consumer = Consumer<String?>(
        providerKey: providerKey,
        builder: (context, value) {
          if (value == null) {
            return Text(valueStringNULL, textDirection: TextDirection.ltr);
          }

          return Text(value, textDirection: TextDirection.ltr);
        });

    // with initial value
    await tester.pumpWidget(consumer);

    // dispose provider's value
    simpleProvider.dispose();

    await tester.pump();
    var valueFinder = find.text(valueStringNULL);
    expect(valueFinder, findsOneWidget);
  });
}
