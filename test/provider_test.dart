import 'package:flutter_test/flutter_test.dart';

import 'package:my_dispatcher/index.dart';

const valueString = 'HELLO';

main() {
  testWidgets("Dispatcher: basic usage", (WidgetTester tester) async {
    Dispatcher("SIMPLE_DISPATCHER");
  });
}
