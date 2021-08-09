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
  testWidgets("Fetch Dispatcher: Parallel request using same cache key",
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

    int successCount = 0;
    int builderCount = 0;

    final cacheKey = "FETCH_PRODUCT_1";

    var fetchs = Column(
      children: [
        Fetch<Product>(
            params: params,
            request: getProduct,
            cacheFirst: true,
            createCache: (response, fetchState) {
              return FetchCache(key: cacheKey);
            },
            onSuccess: (response, fetchState) {
              successCount++;
              responseFetch1 = response;
            },
            builder: (fetchState) {
              builderCount++;
              return getProductBuidler(fetchState);
            }),
        Fetch<Product>(
            params: params,
            request: getProduct,
            cacheFirst: true,
            createCache: (response, fetchState) {
              return FetchCache(key: cacheKey);
            },
            onSuccess: (response, fetchState) {
              successCount++;
            },
            onResponseChange: (response, old) {
              responseFetch2 = response;
            },
            builder: (fetchState) {
              builderCount++;
              return getProductBuidler(fetchState);
            }),
        Fetch<Product>(
            params: params,
            request: getProduct,
            cacheFirst: true,
            createCache: (response, fetchState) {
              return FetchCache(key: cacheKey);
            },
            onSuccess: (response, fetchState) {
              successCount++;
            },
            builder: (fetchState) {
              builderCount++;
              return getProductBuidler(fetchState);
            }),
      ],
    );

    await tester.pumpWidget(fetchs);
    final loadingWidgets = find.text(loadingText);
    expect(loadingWidgets, findsNWidgets(3));

    await tester.pump(Duration(seconds: 1));
    expect(successCount, 1);
    expect(responseFetch1, isNot(null));
    expect(responseFetch2, isNot(null));

    expect(responseFetch1, responseFetch2);

    final productNameWidget = find.text(responseFetch2!.name!);
    expect(productNameWidget, findsNWidgets(3));
  });
}
