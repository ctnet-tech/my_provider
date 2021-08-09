import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:my_dispatcher/index.dart';

import 'resources/product.dart';
import 'resources/product_builders.dart';
import 'resources/product_data.dart';
import 'resources/product_requests.dart';

import 'fetch_lazy_test.mocks.dart';

@GenerateMocks([http.Client])
main() {
  testWidgets("Fetch caching: \"cacheFirst\" shound working correctly",
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
    Product? responseFetch3;

    int onInitCountFetch3 = 0;
    Product? initResponseFetch3;

    var requestCount = 0;
    var successCount = 0;
    var onResponseCount = 0;
    var builderCount = 0;

    final cacheKey = "FETCH_PRODUCT_2";

    var fetch = Column(
      children: [
        Fetch<Product>(
            params: params,
            request: (params) async {
              requestCount++;
              return await getProduct(params);
            },
            createCache: (response, fetchState) {
              return FetchCache(key: cacheKey);
            },
            onSuccess: (response, fetchState) {
              successCount++;
              responseFetch1 = response;
            },
            onResponseChange: (response, old) {
              onResponseCount++;
              responseFetch1 = response;
            },
            builder: (fetchState) {
              builderCount++;

              if (fetchState.loading == true) {
                return Text(
                  loadingText,
                  textDirection: TextDirection.rtl,
                );
              }

              return Column(
                children: [
                  Fetch<Product>(
                      cacheFirst: true,
                      params: params,
                      request: (params) async {
                        requestCount++;
                        return await getProduct(params);
                      },
                      createCache: (response, fetchState) {
                        return FetchCache(key: cacheKey);
                      },
                      onInit: (fetchState) {
                        responseFetch2 = fetchState.response;
                      },
                      onSuccess: (response, fetchState) {
                        successCount++;
                        responseFetch2 = response;
                      },
                      onResponseChange: (response, old) {
                        onResponseCount++;
                        responseFetch2 = response;
                      },
                      builder: (fetchState) {
                        builderCount++;
                        return getProductBuidler(fetchState);
                      }),
                  Fetch<Product>(
                      cacheFirst: false,
                      createCache: (response, fetchState) {
                        return FetchCache(key: cacheKey);
                      },
                      onInit: (fetchState) {
                        onInitCountFetch3++;
                        initResponseFetch3 = fetchState.response;
                      },
                      onSuccess: (response, fetchState) {
                        successCount++;
                        responseFetch3 = response;
                      },
                      onResponseChange: (response, old) {
                        onResponseCount++;
                      },
                      params: params,
                      request: (params) async {
                        requestCount++;
                        return await getProduct(params);
                      },
                      builder: (fetchState) {
                        builderCount++;
                        return getProductBuidler(fetchState);
                      }),
                ],
              );
            })
      ],
    );

    await tester.pumpWidget(fetch);
    var loadingWidgets = find.text(loadingText);
    expect(loadingWidgets, findsNWidgets(1));
    expect(builderCount, 1);

    await tester.pump(Duration(seconds: 1));
    // Fetch_2 reuse Fetch_1 response;
    var productNamesWidgets = find.text(responseFetch1!.name!);
    expect(productNamesWidgets, findsNWidgets(1));
    expect(requestCount, 2);
    expect(successCount, 1);
    expect(onResponseCount, 2);
    expect(builderCount, 4);

    expect(responseFetch1, responseFetch2);
    expect(responseFetch1, isNot(responseFetch3));

    // Fetch_3 start refetching;
    expect(onInitCountFetch3, 1);
    expect(initResponseFetch3, null);

    // After Fetch_3 refetched;
    await tester.pump(Duration(seconds: 1));
    expect(requestCount, 2);
    expect(successCount, 2);
    expect(onResponseCount, 5);
    expect(builderCount, 7);

    expect(responseFetch1, responseFetch2);
    expect(responseFetch1, responseFetch3);

    var productNameWidgets = find.text(responseFetch1!.name!);
    expect(productNameWidgets, findsNWidgets(2));
  });

  testWidgets("Fetch caching: \"cacheDuration\" shound working correctly",
      (WidgetTester tester) async {
    var client = MockClient();
    setClient(client);

    when(client
            .get(Uri.parse("https://$domain$productsPath/${params.productId}")))
        .thenAnswer((_) async {
      await Future.delayed(Duration(seconds: 1));
      return http.Response(productJsonString, 200);
    });

    var requestCount = 0;
    var successCount = 0;
    var onResponseExpiredCount = 0;
    var onResponseChangeCount = 0;
    var builderCount = 0;

    final cacheKey = "FETCH_PRODUCT_3";

    var fetch = Column(
      children: [
        Fetch<Product>(
            params: params,
            request: (params) async {
              requestCount++;
              return await getProduct(params);
            },
            createCache: (response, fetchState) {
              return FetchCache(key: cacheKey, duration: 1000);
            },
            onSuccess: (response, fetchState) {
              successCount++;
            },
            onResponseChange: (response, old) {
              onResponseChangeCount++;
            },
            onCacheExpired: (cache, fetchState) {
              onResponseExpiredCount++;
            },
            builder: (fetchState) {
              builderCount++;
              return getProductBuidler(fetchState);
            })
      ],
    );

    await tester.pumpWidget(fetch);
    var loadingFinder = find.text(loadingText);
    expect(loadingFinder, findsNWidgets(1));

    await tester.pump(Duration(seconds: 1));
    await tester.pump(Duration(seconds: 1));

    expect(requestCount, 1);
    expect(successCount, 1);
    expect(onResponseExpiredCount, 1);
    expect(onResponseChangeCount, 1);
    expect(builderCount, 1 + 1,
        reason: "tester.pump() was given +1 to builderCount");
  });
}
