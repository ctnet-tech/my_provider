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
  testWidgets(
      "Fetch Provider: \"Fetch.forceSetResponse\" shound working correctly",
      (WidgetTester tester) async {
    var client = MockClient();
    setClient(client);

    when(client.get(Uri.parse("https://$domain$productsPath/1")))
        .thenAnswer((_) async {
      await Future.delayed(Duration(seconds: 1));
      return http.Response(productJsonString, 200);
    });

    when(client.delete(Uri.parse("https://$domain$productsPath/1")))
        .thenAnswer((_) async {
      await Future.delayed(Duration(seconds: 1));
      return http.Response(productJsonString, 200);
    });

    final providerKey = "GET_PRODUCT_DATA";

    var fetch = Fetch<Product?>(
      providerKey: providerKey,
      params: ProductFetchParams(productId: 1),
      request: getProduct,
      builder: (getProductState) {
        if (getProductState.loading == true) {
          return Text("LOADING", textDirection: TextDirection.ltr);
        }

        if (getProductState.response?.isDeleted == true) {
          return Text("DELETED", textDirection: TextDirection.ltr);
        }

        return Fetch<Product>(
            lazy: true,
            params: params,
            request: deleteProduct,
            onSuccess: (deletedProduct, _) {
              getProductState.response?.isDeleted = true;
              Fetch.forceSetResponse(providerKey, getProductState.response);
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

  testWidgets("Fetch Provider: Using the same key will use the same response",
      (WidgetTester tester) async {
    var client = MockClient();
    setClient(client);

    when(client
            .get(Uri.parse("https://$domain$productsPath/${params.productId}")))
        .thenAnswer((_) async {
      await Future.delayed(Duration(seconds: 1));
      return http.Response(productJsonString, 200);
    });

    Product? responseFetch1;
    Product? responseFetch2;

    final providerKey = "FETCH_PRODUCT_1";

    var fetchs = Column(
      children: [
        Fetch<Product>(
            providerKey: providerKey,
            onSuccess: (response, fetchState) {
              responseFetch1 = response;
            },
            params: params,
            request: getProduct,
            builder: getProductBuidler),
        Fetch<Product>(
            providerKey: providerKey,
            onResponseChange: (response, old) {
              responseFetch2 = response;
            },
            params: params,
            request: getProduct,
            builder: getProductBuidler),
        Fetch<Product>(
            providerKey: providerKey,
            params: params,
            request: getProduct,
            builder: getProductBuidler)
      ],
    );

    await tester.pumpWidget(fetchs);
    final loadingWidgets = find.text(loadingText);
    expect(loadingWidgets, findsNWidgets(3));

    await tester.pump(Duration(seconds: 1));

    expect(responseFetch1, isNot(null));
    expect(responseFetch2, isNot(null));

    expect(responseFetch1, responseFetch2);

    final productNameWidget = find.text(responseFetch2!.name!);
    expect(productNameWidget, findsNWidgets(3));
  });
}
