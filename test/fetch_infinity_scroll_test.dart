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
main()
{
  testWidgets("Infinity Scroll: test infinity scroll", (WidgetTester tester)
  async {
    var client = MockClient();
    setClient(client);

    when(client.get(Uri.parse("https://domain.com/products"),))
        .thenAnswer((_)
    async {
      await Future.delayed(Duration(seconds: 1));
      return http.Response(listProductJsonString, 200);
    });
    int? length;
    var fetch = Fetch<List<Product?>, ProductFetchParams>(
        providerKey: "Fetch_Infinity_Scroll",
        request: getProducts,
        params: params,
        isInfinityScroll: true,
        onSuccess: (response, fetchState)
        {
          length = fetchState.response!.length;
        },
        builder: infinityScrollProductBuilder);

    await tester.pumpWidget(fetch);
    await tester.pump(Duration(seconds: 1));
    var textButton = find.byType(ElevatedButton);
    await tester.tap(textButton);
    await tester.pump(Duration(seconds: 1));
    expect(length, 2);
  });

  testWidgets("Pagination test", (WidgetTester tester)
  async {
    var client = MockClient();
    setClient(client);

    when(client.get(Uri.parse("https://domain.com/products"),))
        .thenAnswer((_)
    async {
      await Future.delayed(Duration(seconds: 1));
      return http.Response(listProductJsonString, 200);
    });
    int? length;
    var fetch = Fetch<List<Product?>, ProductFetchParams>(
        providerKey: "Fetch_Infinity_Scroll",
        request: getProducts,
        params: params,
        isInfinityScroll: true,
        onSuccess: (response, fetchState)
        {
          length = fetchState.response!.length;
        },
        builder: infinityScrollProductBuilder);

    await tester.pumpWidget(fetch);
    await tester.pump(Duration(seconds: 1));
    var textButton = find.byType(ElevatedButton);
    await tester.tap(textButton);
    await tester.pump(Duration(seconds: 1));
    expect(length, 2);
  });
}