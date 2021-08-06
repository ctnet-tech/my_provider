import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:my_provider/index.dart';

import 'fetch_lazy_test.mocks.dart';
import 'resources/product.dart';
import 'resources/product_builders.dart';
import 'resources/product_data.dart';
import 'resources/product_requests.dart';

@GenerateMocks([http.Client])
main() {
  testWidgets("Lazy Fetch: with initial params", (WidgetTester tester) async {
    var client = MockClient();
    setClient(client);

    when(client.delete(Uri.parse("https://$domain$productsPath/1")))
        .thenAnswer((_) async {
      await Future.delayed(Duration(seconds: 1));
      return http.Response(productJsonString, 200);
    });

    var fetch = Fetch<Product>(
        lazy: true,
        params: params,
        request: deleteProduct,
        builder: deleteProducrtBuidler);

    await tester.pumpWidget(fetch);

    var textButton = find.byType(ElevatedButton);
    await tester.tap(textButton);
    await tester.pump(Duration(seconds: 1));

    var valueFinder = find.text(productData.name!);
    expect(valueFinder, findsOneWidget);
  });

  testWidgets("Lazy Fetch: with lazy params", (WidgetTester tester) async {
    var client = MockClient();
    setClient(client);

    when(client.post(Uri.parse("https://$domain$productsPath"), body: body))
        .thenAnswer((_) async {
      await Future.delayed(Duration(seconds: 1));
      return http.Response(productJsonString, 200);
    });

    var fetch = Fetch<Product>(
        lazy: true, request: postProduct, builder: createProductBuilder);

    await tester.pumpWidget(fetch);

    var textButton = find.byType(ElevatedButton);
    await tester.tap(textButton);
    await tester.pump(Duration(seconds: 1));

    var valueFinder = find.text(productData.name!);
    expect(valueFinder, findsOneWidget);
  });
}
