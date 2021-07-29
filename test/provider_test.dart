import 'package:flutter_test/flutter_test.dart';

import 'package:my_provider/index.dart';

const valueString = 'HELLO';

main() {
  testWidgets("Provider: basic usage", (WidgetTester tester) async {
    Provider(providerKey: "SIMPLE_PROVIDER", value: valueString);
  });
}
