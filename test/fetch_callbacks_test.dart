import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:my_dispatcher/index.dart';

import 'fetch_lazy_test.mocks.dart';
import 'resources/product.dart';
import 'resources/product_builders.dart';
import 'resources/product_data.dart';
import 'resources/product_requests.dart';

@GenerateMocks([http.Client])
main() {
  testWidgets("Fetch callback: success", (WidgetTester tester) async {
    var client = MockClient();
    setClient(client);

    when(client.delete(
            Uri.parse("https://$domain$productsPath/${params.productId}")))
        .thenAnswer((_) async {
      await Future.delayed(Duration(seconds: 1));
      return http.Response(productJsonString, 200);
    });

    var onSuccessCallback = 0;

    var fetch = Fetch<Product>(
        lazy: true,
        onSuccess: (response, _) {
          onSuccessCallback++;
        },
        params: params,
        request: deleteProduct,
        builder: deleteProductBuidler);

    await tester.pumpWidget(fetch);

    var deleteButton = find.byType(ElevatedButton);
    await tester.tap(deleteButton);

    // Waiting for delete
    await tester.pump(Duration(seconds: 1));
    expect(onSuccessCallback, 0);

    // Delete successfully.
    await tester.pump(Duration(seconds: 1));
    expect(onSuccessCallback, 1);
  });

  testWidgets("Fetch callback: onError should working correctly",
      (WidgetTester tester) async {
    var client = MockClient();
    setClient(client);

    when(client.post(Uri.parse("https://$domain$productsPath"), body: body))
        .thenAnswer((_) async {
      await Future.delayed(Duration(seconds: 1));
      return http.Response(productJsonString, 400);
    });

    var onErrorCount = 0;

    var fetch = Fetch<Product>(
        lazy: true,
        onError: (error) {
          onErrorCount++;
        },
        request: postProduct,
        builder: createProductBuilder);

    await tester.pumpWidget(fetch);

    var deleteButton = find.byType(ElevatedButton);
    await tester.tap(deleteButton);

    // Waiting for delete
    await tester.pump(Duration(seconds: 1));
    expect(onErrorCount, 0);

    // Delete failured
    await tester.pump(Duration(seconds: 1));
    expect(onErrorCount, 1);
  });
}
