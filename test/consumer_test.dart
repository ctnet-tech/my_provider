import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:my_provider/index.dart';

const valueString = 'HELLO';
const valueStringNext = 'GOOD BYE';
const valueStringNULL = 'NULL';

main() {
  testWidgets("Consumer: basic usage", (WidgetTester tester) async {
    const providerKey = 'SIMPLE_PROVIDER_1';

    Provider<String?>(providerKey).setValue(valueString);

    var consumer = Consumer<String>(
        providerKey: providerKey,
        builder: (context, value) {
          return Text(value!, textDirection: TextDirection.ltr);
        });

    // with initial value
    await tester.pumpWidget(consumer);
    var valueFinder = find.text(valueString);
    expect(valueFinder, findsOneWidget);
  });

  testWidgets("Consumer: update provider's value", (WidgetTester tester) async {
    const providerKey = 'SIMPLE_PROVIDER_2';

    var simpleProvider = Provider<String?>(providerKey).setValue(valueString);

    var consumer = Consumer<String>(
        providerKey: providerKey,
        builder: (context, value) {
          return Text(value!, textDirection: TextDirection.ltr);
        });

    // with initial value
    await tester.pumpWidget(consumer);

    // update provider's value
    simpleProvider.setValue(valueStringNext);
    await tester.pump();
    var valueFinder = find.text(valueStringNext);
    expect(valueFinder, findsOneWidget);
  });
}
