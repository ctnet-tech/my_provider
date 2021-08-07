import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:my_provider/fetch_list.dart';
import 'package:my_provider/index.dart';

import 'fetch_lazy_test.mocks.dart';
import 'resources/product.dart';
import 'resources/product_builders.dart';
import 'resources/product_data.dart';
import 'resources/product_requests.dart';

@GenerateMocks([http.Client])
main() {
  testWidgets("Fetch caching: list fetch", (WidgetTester tester) async {
    var client = MockClient();
    setClient(client);

    when(client.get(Uri.parse("https://domain.com/products/1")))
        .thenAnswer((_) async {
      await Future.delayed(Duration(seconds: 1));
      return http.Response(listProductJsonString, 200);
    });


    var fetch = MaterialApp(
      home: Scaffold(
        body: Fetch<List<Product>?, int>(
            providerKey: "FETCH_LIST_PRODUCT",
            params: 1,
            request: getListProduct,
            builder: (fetchState) {
              if (fetchState.loading == true) {
                return Text(loadingText, textDirection: TextDirection.ltr);
              }

              if (fetchState.response != null) {
                return FetchList<Product>(
                  builderLoading: (context, val) {
                    return Text("Loadding...");
                  },
                  itemsLoadFist: 10,
                  itemsPerPage: 10,
                  listValue: fetchState.response!,
                  buildChild: (context, product) {
                    var txt = "Test_PRODUCT_${product.id}";
                    return ListTile(
                        title: Text(txt, textDirection: TextDirection.ltr));
                  },
                );
              }

              return Text("NULL", textDirection: TextDirection.rtl);
            }),
      ),
    );

    // moi man hinh test offset  500>=size>450
    // ban dau
    var fetchList = 'Test_PRODUCT_9';
    var textNotHas = 'Test_PRODUCT_15';
    await tester.pumpWidget(fetch);
    await tester.pump(Duration(seconds: 1));
    var listText = find.text(fetchList);
    expect(listText, findsOneWidget);
    var testNotHasText = find.text(textNotHas);
    expect(testNotHasText, findsNothing);

    // load lan 1
    final listView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView));
    final ctrl = listView.controller;
    ctrl!.jumpTo(ctrl.offset + 500);
    await tester.pumpAndSettle(Duration(seconds: 1));
    fetchList = 'Test_PRODUCT_19';
    textNotHas = 'Test_PRODUCT_20';
    listText = find.text(fetchList);
    expect(listText, findsOneWidget);
    testNotHasText = find.text(textNotHas);
    expect(testNotHasText, findsNothing);


    // load lan 2
    ctrl.jumpTo(ctrl.offset + 1000);
    await tester.pumpAndSettle(Duration(seconds: 1));
    fetchList = 'Test_PRODUCT_29';
    textNotHas = 'Test_PRODUCT_30';
    listText = find.text(fetchList);
    expect(listText, findsOneWidget);
    testNotHasText = find.text(textNotHas);
    expect(testNotHasText, findsNothing);


    // load lan 3
    ctrl.jumpTo(ctrl.offset + 1500);
    await tester.pumpAndSettle(Duration(seconds: 1));
    fetchList = 'Test_PRODUCT_39';
    textNotHas = 'Test_PRODUCT_40';
    listText = find.text(fetchList);
    expect(listText, findsOneWidget);
    testNotHasText = find.text(textNotHas);
    expect(testNotHasText, findsNothing);
  });


  testWidgets(
      "Fetch caching: list fetch load more", (WidgetTester tester) async {
    var client = MockClient();
    setClient(client);

    when(client.get(Uri.parse("https://domain.com/products/1")))
        .thenAnswer((_) async {
      await Future.delayed(Duration(seconds: 1));
      return http.Response(listProductJsonString, 200);
    });


    var fetch = MaterialApp(
      home: Scaffold(
        body: Fetch<List<Product>?, int>(
            providerKey: "FETCH_LIST_PRODUCT",
            params: 1,
            request: getListProduct,
            builder: (fetchState) {
              if (fetchState.loading == true) {
                return Text(loadingText, textDirection: TextDirection.ltr);
              }

              if (fetchState.response != null) {
                return FetchList<Product>(
                  builderLoading: (context, val) {
                    return Text("Loadding...");
                  },
                  itemsLoadFist: 10,
                  itemsPerPage: 10,
                  listValue: fetchState.response!,
                  buildChild: (context, product) {
                    var txt = "Test_PRODUCT_${product.id}";
                    return ListTile(
                        title: Text(txt, textDirection: TextDirection.ltr));
                  },
                  loadFull: (fetchList) {
                    fetchList.addMoreData(list: listProductAddMore);
                  },
                );
              }

              return Text("NULL", textDirection: TextDirection.rtl);
            }),
      ),
    );

    // moi man hinh test offset  500>=size>450
    // ban dau
    var fetchList = 'Test_PRODUCT_9';
    var textNotHas = 'Test_PRODUCT_15';
    await tester.pumpWidget(fetch);
    await tester.pump(Duration(seconds: 1));
    var listText = find.text(fetchList);
    expect(listText, findsOneWidget);
    var testNotHasText = find.text(textNotHas);
    expect(testNotHasText, findsNothing);


    int lastScroll = 0;
    final listView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView));
    final ctrl = listView.controller;

    for (int i = 500; i <= 4500; i += 500) {
      lastScroll = i;
      ctrl!.jumpTo(ctrl.offset + i);
      await tester.pumpAndSettle(Duration(seconds: 1));
    }

    var textLast = 'Test_PRODUCT_99';
    var findText = find.text(textLast);
    expect(findText, findsOneWidget);


    ctrl!.jumpTo(ctrl.offset + 500 + lastScroll);
    await tester.pumpAndSettle(Duration(seconds: 1));

    textLast = 'Test_PRODUCT_109';
    findText = find.text(textLast);
    expect(findText, findsOneWidget);
  });
}
