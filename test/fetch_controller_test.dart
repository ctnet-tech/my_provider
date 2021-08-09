import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

import 'package:my_dispatcher/index.dart';

import 'fetch_controller_test.mocks.dart';
import 'resources/product.dart';
import 'resources/product_builders.dart';
import 'resources/product_data.dart';
import 'resources/product_requests.dart';

@GenerateMocks([http.Client])
main() {
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

  testWidgets(
      "Fetch Controller: \"FetchController.setCache\" shound working correctly",
      (WidgetTester tester) async {
    final cacheKey = "GET_PRODUCT_DATA";

    var fetch = Fetch<Product?>(
      name: "GET_PRODUCT",
      params: ProductFetchParams(productId: 1),
      request: getProduct,
      createCache: (response, fetchState) {
        return FetchCache(key: cacheKey);
      },
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
              final fetchController = Fetch.getController("GET_PRODUCT")!;
              fetchController.setCache(
                  FetchCache(key: cacheKey, response: deletedProduct));
            },
            builder: deleteProductBuidler);
      },
    );

    await tester.pumpWidget(fetch);

    // Waiting for fisrt response
    await tester.pump(Duration(seconds: 1));

    // Trigger delete request
    var deleteButton = find.byType(ElevatedButton);
    await tester.tap(deleteButton);

    // Display loading whole request
    await tester.pump(Duration(seconds: 1));
    var loadingtextWidget = find.text(loadingText);
    expect(loadingtextWidget, findsOneWidget);

    // Display "DELETED" after request successfuly
    await tester.pump(Duration(seconds: 1));
    var deletedTextwidget = find.text(deletedText);
    expect(deletedTextwidget, findsOneWidget);
  });

  testWidgets(
      "Fetch Controller: \"FetchController.setResponse\" shound working correctly",
      (WidgetTester tester) async {
    var fetch = Fetch<Product?>(
      name: "GET_PRODUCT_SET_RESPONSE",
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
              Fetch.getController("GET_PRODUCT_SET_RESPONSE")!
                  .setResponse(deletedProduct);
            },
            builder: deleteProductBuidler);
      },
    );

    await tester.pumpWidget(fetch);

    // Waiting for fisrt response
    await tester.pump(Duration(seconds: 1));

    // Trigger delete request
    var deleteButton = find.byType(ElevatedButton);
    await tester.tap(deleteButton);

    // Display loading whole request
    await tester.pump(Duration(seconds: 1));
    var loadingtextWidget = find.text(loadingText);
    expect(loadingtextWidget, findsOneWidget);

    // Display "DELETED" after request successfuly
    await tester.pump(Duration(seconds: 1));
    var deletedTextwidget = find.text(deletedText);
    expect(deletedTextwidget, findsOneWidget);
  });

  testWidgets(
      "Fetch Controller: \"FetchController.fetch\" shound working correctly",
      (WidgetTester tester) async {
    var successCount = 0;
    var builderCount = 0;

    var fetch = Fetch<Product?>(
      name: "GET_PRODUCT_SET_RESPONSE",
      params: ProductFetchParams(productId: 1),
      request: getProduct,
      onSuccess: (response, _) {
        successCount++;
      },
      builder: (getProductState) {
        builderCount++;
        if (getProductState.loading == true) {
          return Text("LOADING", textDirection: TextDirection.ltr);
        }

        return MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              child: Text("Refetch", textDirection: TextDirection.ltr),
              onPressed: () {
                Fetch.getController("GET_PRODUCT_SET_RESPONSE")!.fetch(null);
              },
            ),
          ),
        );
      },
    );

    await tester.pumpWidget(fetch);
    expect(builderCount, 1);

    // Waiting for fisrt response
    await tester.pump(Duration(seconds: 1));
    expect(successCount, 1);
    expect(builderCount, 2);

    // Trigger refetch
    var buttonFinder = find.byType(ElevatedButton);
    await tester.tap(buttonFinder);

    // Display loading whole request
    await tester.pump(Duration(seconds: 1));
    expect(builderCount, 3);
    var loadingtextWidget = find.text(loadingText);
    expect(loadingtextWidget, findsOneWidget);

    // After request successfuly
    await tester.pump(Duration(seconds: 1));
    expect(successCount, 2);
    expect(builderCount, 4);
  });
}
