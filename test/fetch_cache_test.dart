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
  testWidgets("Fetch caching: one state for many fetch",
      (WidgetTester tester) async {
    var client = MockClient();
    setClient(client);

    when(client
            .get(Uri.parse("https://domain.com/products/${params.productId}")))
        .thenAnswer((_) async {
      await Future.delayed(Duration(seconds: 1));
      return http.Response(productJsonString, 200);
    });

    dynamic fetchState_1;
    dynamic fetchState_2;

    var fetch = Column(
      children: [
        Fetch<Product?, ProductFetchParams>(
            providerKey: "FETCH_PRODUCT",
            onSuccess: (response, fetchState) {
              fetchState_1 = fetchState;
            },
            params: params,
            request: getProduct,
            builder: getProductBuidler),
        Fetch<Product?, ProductFetchParams>(
            providerKey: "FETCH_PRODUCT",
            onSuccess: (response, fetchState) {
              fetchState_2 = fetchState;
            },
            params: params,
            request: getProduct,
            builder: getProductBuidler)
      ],
    );

    await tester.pumpWidget(fetch);
    await tester.pump(Duration(seconds: 1));

    expect(fetchState_1, isNot(null));
    expect(fetchState_2, isNot(null));

    expect(fetchState_1, fetchState_2);
  });

  testWidgets("Fetch caching: reusing existing cache",
      (WidgetTester tester) async {
    var client = MockClient();
    setClient(client);

    when(client
            .get(Uri.parse("https://domain.com/products/${params.productId}")))
        .thenAnswer((_) async {
      await Future.delayed(Duration(seconds: 1));
      return http.Response(productJsonString, 200);
    });

    dynamic fetchState_1;
    dynamic fetchState_2;

    var requestCount = 0;
    var successCount = 0;

    var fetch = Column(
      children: [
        Fetch<Product?, ProductFetchParams>(
          providerKey: "FETCH_PRODUCT",
          cacheDuration: 10000,
          onSuccess: (response, fetchState) {
            successCount++;
            fetchState_1 = fetchState;
          },
          params: params,
          request: (params) async {
            requestCount++;
            return await getProduct(params);
          },
          builder: (fetchState) {
            if (fetchState.loading == true) {
              return Text(
                loadingText,
                textDirection: TextDirection.rtl,
              );
            }

            return Fetch<Product?, ProductFetchParams>(
                providerKey: "FETCH_PRODUCT",
                cacheFirst: true,
                onInit: (fetchState) {
                  fetchState_2 = fetchState;
                },
                onSuccess: (response, fetchState) {
                  successCount++;
                  fetchState_2 = fetchState;
                },
                params: params,
                request: (params) async {
                  requestCount++;
                  return await getProduct(params);
                },
                builder: getProductBuidler);
          },
        ),
      ],
    );

    await tester.pumpWidget(fetch);
    await tester.pump(Duration(seconds: 2));

    expect(requestCount, 1);
    expect(successCount, 1);

    expect(fetchState_1, fetchState_2);
  });

  testWidgets("Fetch caching: fetch via a callback again when cache expires",
      (WidgetTester tester) async {
    var client = MockClient();
    setClient(client);

    when(client
            .get(Uri.parse("https://domain.com/products/${params.productId}")))
        .thenAnswer((_) async {
      await Future.delayed(Duration(seconds: 1));
      return http.Response(productJsonString, 200);
    });

    dynamic fetchState_1;
    dynamic fetchState_2;

    var requestCount = 0;
    var successCount = 0;

    var fetch = Column(
      children: [
        Fetch<Product?, ProductFetchParams>(
          providerKey: "FETCH_PRODUCT",
          cacheDuration: 10000,
          onSuccess: (response, fetchState) {
            successCount++;
            fetchState_1 = fetchState;
          },
          params: params,
          request: (params) async {
            requestCount++;
            return await getProduct(params);
          },
          builder: (fetchState) {
            if (fetchState.loading == true) {
              return Text(
                loadingText,
                textDirection: TextDirection.rtl,
              );
            }

            return Fetch<Product?, ProductFetchParams>(
                providerKey: "FETCH_PRODUCT",
                cacheFirst: true,
                onInit: (fetchState) {
                  fetchState_2 = fetchState;
                },
                onSuccess: (response, fetchState) {
                  successCount++;
                  fetchState_2 = fetchState;
                },
                params: params,
                request: (params) async {
                  requestCount++;
                  return await getProduct(params);
                },
                builder: getProductBuidler);
          },
        ),
      ],
    );

    await tester.pumpWidget(fetch);
    await tester.pump(Duration(seconds: 2));

    expect(requestCount, 1);
    expect(successCount, 1);

    expect(fetchState_1, fetchState_2);
  });
}
