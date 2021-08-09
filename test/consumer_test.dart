import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:my_dispatcher/index.dart';

const valueString = 'HELLO';
const valueStringNext = 'GOOD BYE';
const valueStringNULL = 'NULL';

main() {
  testWidgets("Presenter: basic usage", (WidgetTester tester) async {
    const cacheKey = 'SIMPLE_DISPATCHER_1';

    Dispatcher<String?>(cacheKey).setValue(valueString);

    var presenter = Presenter<String>(
        cacheKey: cacheKey,
        builder: (context, value) {
          return Text(value!, textDirection: TextDirection.ltr);
        });

    // with initial value
    await tester.pumpWidget(presenter);
    var valueFinder = find.text(valueString);
    expect(valueFinder, findsOneWidget);
  });

  testWidgets("Presenter: update dispatcher's value",
      (WidgetTester tester) async {
    const cacheKey = 'SIMPLE_DISPATCHER_2';

    var simpleDispatcher = Dispatcher<String?>(cacheKey).setValue(valueString);

    var presenter = Presenter<String>(
        cacheKey: cacheKey,
        builder: (context, value) {
          return Text(value!, textDirection: TextDirection.ltr);
        });

    // with initial value
    await tester.pumpWidget(presenter);

    // update dispatcher's value
    simpleDispatcher.setValue(valueStringNext);
    await tester.pump();
    var valueFinder = find.text(valueStringNext);
    expect(valueFinder, findsOneWidget);
  });
}
