
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
  testWidgets("Fetch Provider: basic", (WidgetTester tester) async {
    var client = MockClient();
    setClient(client);

    when(client.get(Uri.parse("https://domain.com/products/1")))
        .thenAnswer((_) async {
      await Future.delayed(Duration(seconds: 1));
      return http.Response(productJsonString, 200);
    });

    when(client.delete(
        Uri.parse("https://domain.com/products/${params.body!.id}")))
        .thenAnswer((_) async {
      await Future.delayed(Duration(seconds: 1));
      return http.Response(productJsonString, 200);
    });

    var fetch = Fetch<Product?, ProductFetchParams>(
      providerKey: "GET_PRODUCT_DATA",
      params: ProductFetchParams(productId: 1),
      request: getProduct,
      builder: (getProductState) {
        if (getProductState.loading == true) {
          return Text("LOADING", textDirection: TextDirection.ltr);
        }

        if (getProductState.response?.isDeleted == true) {
          return Text("DELETED", textDirection: TextDirection.ltr);
        }

        return Fetch<Product?, ProductFetchParams>(
            lazy: true,
            params: params,
            request: deleteProduct,
            onSuccess: (deletedProduct, _) {
              getProductState.response?.isDeleted = true;
              Fetch.setResponse("GET_PRODUCT_DATA", getProductState.response);
            },
            builder: deleteProducrtBuidler);
      },
    );

    await tester.pumpWidget(fetch);
    await tester.pump(Duration(seconds: 1));

    var deleteButton = find.byType(ElevatedButton);
    await tester.tap(deleteButton);
    await tester.pump(Duration(seconds: 1));

    var deletedText = find.text("DELETED");
    expect(deletedText, findsOneWidget);
  });
}