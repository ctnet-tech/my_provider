import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:my_dispatcher/index.dart';

import 'fetch_panigation_test.mocks.dart';
import 'fetch_test.dart';
import 'resources/product.dart';
import 'resources/product_data.dart';
import 'resources/product_requests.dart';

@GenerateMocks([http.Client])
main() {
  final client = MockClient();
  setClient(client);

  when(client.get(Uri.parse("https://$domain$productsPath?page=1")))
      .thenAnswer((_) async {
    await Future.delayed(Duration(seconds: 1));
    return http.Response(productJsonPage1, 200);
  });

  when(client.get(Uri.parse("https://$domain$productsPath?page=2")))
      .thenAnswer((_) async {
    await Future.delayed(Duration(seconds: 1));
    return http.Response(productJsonPage2, 200);
  });

  when(client.get(Uri.parse("https://$domain$productsPath?page=3")))
      .thenAnswer((_) async {
    await Future.delayed(Duration(seconds: 1));
    return http.Response(productJsonPage3, 200);
  });

  testWidgets("Fetch Pagination: Cache should working correctly",
      (tester) async {
    var cacheCount = 0;
    var builderCount = 0;
    var successCount = 0;

    List<Product>? currentResponse;

    var fetch = Fetch<List<Product>>(
        request: getProducts,
        params: ProductFetchParams(pagi: Pagination(1)),
        cacheFirst: true,
        onSuccess: (r, f) {
          successCount++;
        },
        createCache: (params, response) {
          cacheCount++;
          return FetchCache(
              key: ["PRODUCTS", params.pagi.page], duration: 5000);
        },
        builder: (fetchState) {
          builderCount++;
          currentResponse = fetchState.response;

          if (fetchState.loading == true) {
            return Text(loadingText, textDirection: TextDirection.ltr);
          }

          return MaterialApp(
              home: Column(
            children: [
              Column(
                children: fetchState.response!.map<Widget>((product) {
                  return Text(product.name!, textDirection: TextDirection.ltr);
                }).toList(),
              ),
              ElevatedButton(
                  key: Key("buttonPage1"),
                  onPressed: () {
                    fetchState.fetch(ProductFetchParams(pagi: Pagination(1)));
                  },
                  child: Text("Page 1", textDirection: TextDirection.ltr)),
              ElevatedButton(
                  key: Key("buttonPage2"),
                  onPressed: () {
                    fetchState.fetch(ProductFetchParams(pagi: Pagination(2)));
                  },
                  child: Text("Page 2", textDirection: TextDirection.ltr))
            ],
          ));
        });
    await tester.pumpWidget(fetch);
    // Step 1: Loading progress
    var loadingTextWidget = find.text(loadingText);
    expect(loadingTextWidget, findsOneWidget);
    expect(cacheCount, 1);
    expect(builderCount, 1);
    expect(successCount, 0);

    // Step 1: Initial build page 1 products
    await tester.pump(Duration(seconds: 1));
    expect(cacheCount, 2);
    expect(builderCount, 2);
    expect(successCount, 1);
    expect(ProductFactory.listToJson(currentResponse!), productJsonPage1);

    // Click page 2 button
    var page2ButtonWidget = find.byKey(Key("buttonPage2"));
    await tester.tap(page2ButtonWidget);
    await tester.pump(Duration(seconds: 1));
    expect(builderCount, 3);

    await tester.pump(Duration(seconds: 1));
    expect(cacheCount, 4);
    expect(builderCount, 4);
    expect(successCount, 2);
    expect(ProductFactory.listToJson(currentResponse!), productJsonPage2);

    // Click to back page 1
    var page1ButtonWidget = find.byKey(Key("buttonPage1"));
    await tester.tap(page1ButtonWidget);
    await tester.pump(Duration(seconds: 1));

    expect(cacheCount, 5);
    expect(builderCount, 5);
    expect(successCount, 2);
    expect(ProductFactory.listToJson(currentResponse!), productJsonPage1);

    // Click page 2 button after page 2 cache expired.
    await tester.pump(Duration(seconds: 5));
    await tester.tap(page2ButtonWidget);
    expect(cacheCount, 5 + 1);
    await tester.pump(Duration(seconds: 1));

    expect(builderCount, 5 + 1);
    loadingTextWidget = find.text(loadingText);
    expect(loadingTextWidget, findsOneWidget);

    await tester.pump(Duration(seconds: 1));

    expect(cacheCount, 6 + 1);
    expect(builderCount, 6 + 1);
    expect(successCount, 3);
    expect(ProductFactory.listToJson(currentResponse!), productJsonPage2);

    // Temp-fix Timmer
    await tester.pump(Duration(seconds: 10));
  });

  testWidgets("Fetch Pagination: Infinity-scroll should working correctly",
      (tester) async {
    var cacheCount = 0;
    var builderCount = 0;
    var successCount = 0;

    List<Product>? currentResponse;
    List<Product> totalProducts = [];

    final testProductsStage1 = ProductFactory.createList(productJsonPage1);
    final testProductsStage2 = ProductFactory.createList(productJsonPage2);
    final testProductsStage3 = ProductFactory.createList(productJsonPage3);

    var fetch = Fetch<List<Product>>(
        request: getProducts,
        params: ProductFetchParams(pagi: Pagination(1)),
        cacheFirst: true,
        onSuccess: (r, f) {
          successCount++;
        },
        createCache: (params, response) {
          cacheCount++;
          return FetchCache(
              key: ["PRODUCTS", "INFINITY_SCROLL", params.pagi.page],
              duration: 5000);
        },
        builder: (fetchState) {
          builderCount++;
          currentResponse = fetchState.response;

          var products = fetchState.caches
              .expand(((e) => e.response ?? <Product>[]))
              .toList();

          totalProducts = products;

          var showLoading = fetchState.loading == true && products.isEmpty;

          if (showLoading) {
            return Text(loadingText, textDirection: TextDirection.ltr);
          }

          return MaterialApp(
              home: Column(
            children: [
              Column(
                children: products.map<Widget>((product) {
                  return Text(product.name!, textDirection: TextDirection.ltr);
                }).toList(),
              ),
              ElevatedButton(
                  key: Key("buttonPage1"),
                  onPressed: () {
                    fetchState.fetch(ProductFetchParams(pagi: Pagination(1)));
                  },
                  child: Text("Page 1", textDirection: TextDirection.ltr)),
              ElevatedButton(
                  key: Key("buttonPage2"),
                  onPressed: () {
                    fetchState.fetch(ProductFetchParams(pagi: Pagination(2)));
                  },
                  child: Text("Page 2", textDirection: TextDirection.ltr)),
              ElevatedButton(
                  key: Key("buttonPage3"),
                  onPressed: () {
                    fetchState.fetch(ProductFetchParams(pagi: Pagination(3)));
                  },
                  child: Text("Page 3", textDirection: TextDirection.ltr))
            ],
          ));
        });
    await tester.pumpWidget(fetch);
    // Step 1: Loading progress
    var loadingTextWidget = find.text(loadingText);
    expect(loadingTextWidget, findsOneWidget);
    expect(cacheCount, 1);
    expect(builderCount, 1);
    expect(successCount, 0);

    // Step 1: Initial build page 1 products
    await tester.pump(Duration(seconds: 1));
    expect(cacheCount, 2);
    expect(builderCount, 2);
    expect(successCount, 1);
    expect(ProductFactory.listToJson(currentResponse!), productJsonPage1);
    expect(ProductFactory.listToJson(totalProducts),
        ProductFactory.listToJson(testProductsStage1));

    // Click page 2 button
    var page2ButtonWidget = find.byKey(Key("buttonPage2"));
    await tester.tap(page2ButtonWidget);
    await tester.pump(Duration(seconds: 1));
    expect(builderCount, 3);

    await tester.pump(Duration(seconds: 1));
    expect(builderCount, 4);
    expect(cacheCount, 4);
    expect(successCount, 2);
    expect(ProductFactory.listToJson(currentResponse!), productJsonPage2);
    expect(
        ProductFactory.listToJson(totalProducts),
        ProductFactory.listToJson([testProductsStage1, testProductsStage2]
            .expand((e) => e)
            .toList()));

    // Click page 3 button
    var page3ButtonWidget = find.byKey(Key("buttonPage3"));
    await tester.tap(page3ButtonWidget);
    await tester.pump(Duration(seconds: 1));
    expect(builderCount, 5);

    await tester.pump(Duration(seconds: 1));
    expect(builderCount, 6);
    expect(cacheCount, 6);
    expect(successCount, 3);
    expect(ProductFactory.listToJson(currentResponse!), productJsonPage3);
    expect(
        ProductFactory.listToJson(totalProducts),
        ProductFactory.listToJson([
          testProductsStage1,
          testProductsStage2,
          testProductsStage3
        ].expand((e) => e).toList()));

    // Temp-fix Timmer
    await tester.pump(Duration(seconds: 10));
  });
}
