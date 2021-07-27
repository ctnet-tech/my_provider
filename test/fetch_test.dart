import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:my_provider/index.dart';
import 'package:http/http.dart' as http;

import 'fetch_test.mocks.dart';
import 'resources/product.dart';

const jsonString = '{"id": 1, "name": "cat", "type": "pet"}';
var productData = ProductFactory.create(jsonString);

const fetchExceptionMessage = 'UNKNOW_EXCEPTION';
const fetchErrorMessage = 'PRODUCT_NOT_EXIST';
const fetchResponseText = 'RESPONSE';
const nullText = 'NULL';
const loadingText = 'NULL';

MockClient? client;

requestString(dynamic params) async {
  final response =
      await client!.get(Uri.parse("https://domain.com/get-string"));
  return response.body;
}

requestJson(dynamic params) async {
  final response = await client!.get(Uri.parse("https://domain.com/get-json"));
  var product = ProductFactory.create(response.body);
  return product;
}

requestError(dynamic params) async {
  final response = await client!.get(Uri.parse("https://domain.com/get-error"));
  throw FetchError(httpStatus: response.statusCode, message: response.body);
}

requestException(dynamic params) async {
  final response =
      await client!.get(Uri.parse("https://domain.com/get-exception"));
  return response.body;
}

@GenerateMocks([http.Client])
main() {
  testWidgets("Fetch: request string", (WidgetTester tester) async {
    client = MockClient();

    when(client!.get(Uri.parse("https://domain.com/get-string")))
        .thenAnswer((_) async {
      await Future.delayed(Duration(seconds: 1));
      return http.Response(fetchResponseText, 200);
    });

    var fetch = Fetch<String?, dynamic>(
        request: requestString,
        builder: (fetchState) {
          if (fetchState.response == null) {
            return Text(nullText, textDirection: TextDirection.ltr);
          }
          return Text(fetchState.response!, textDirection: TextDirection.ltr);
        });

    await tester.pumpWidget(fetch);
    var valueFinder = find.text(nullText);
    expect(valueFinder, findsOneWidget);

    await tester.pump(Duration(seconds: 1));
    valueFinder = find.text(fetchResponseText);
    expect(valueFinder, findsOneWidget);
  });

  testWidgets("Fetch: request json", (WidgetTester tester) async {
    client = MockClient();

    when(client!.get(Uri.parse("https://domain.com/get-json")))
        .thenAnswer((_) async {
      await Future.delayed(Duration(seconds: 1));
      return http.Response('{"id": 1, "name": "cat", "type": "pet"}', 200);
    });

    var fetch = Fetch<Product?, dynamic>(
        request: requestJson,
        builder: (fetchState) {
          if (fetchState.response == null) {
            return Text(nullText, textDirection: TextDirection.ltr);
          }

          return Text(fetchState.response!.name!,
              textDirection: TextDirection.ltr);
        });

    await tester.pumpWidget(fetch);
    var valueFinder = find.text(nullText);
    expect(valueFinder, findsOneWidget);

    await tester.pump(Duration(seconds: 1));
    valueFinder = find.text(productData.name!);
    expect(valueFinder, findsOneWidget);
  });

  testWidgets("Fetch: server status error", (WidgetTester tester) async {
    client = MockClient();

    when(client!.get(Uri.parse("https://domain.com/get-error")))
        .thenAnswer((_) async {
      await Future.delayed(Duration(seconds: 1));
      return http.Response(fetchErrorMessage, 404);
    });

    var fetch = Fetch<Product?, dynamic>(
        request: requestError,
        builder: (response) {
          if (response.loading == true) {
            return Text(nullText, textDirection: TextDirection.ltr);
          }

          return Text(response.error!.message,
              textDirection: TextDirection.ltr);
        });

    await tester.pumpWidget(fetch);
    var valueFinder = find.text(nullText);
    expect(valueFinder, findsOneWidget);

    await tester.pump(Duration(seconds: 1));
    valueFinder = find.text(fetchErrorMessage);
    expect(valueFinder, findsOneWidget);
  });

  testWidgets("Fetch: server status error", (WidgetTester tester) async {
    client = MockClient();

    when(client!.get(Uri.parse("https://domain.com/get-exception")))
        .thenAnswer((_) async {
      throw Exception(fetchExceptionMessage);
    });

    var fetch = Fetch<Product?, dynamic>(
        request: requestException,
        builder: (response) {
          if (response.exception != null) {
            return Text(response.exception!.message,
                textDirection: TextDirection.ltr);
          }

          if (response.response == null) {
            return Text(nullText, textDirection: TextDirection.ltr);
          }

          return Text("", textDirection: TextDirection.ltr);
        });

    await tester.pumpWidget(fetch);
    var valueFinder = find.text(nullText);
    expect(valueFinder, findsOneWidget);

    await tester.pump(Duration(seconds: 1));
    valueFinder = find.text("Exception: $fetchExceptionMessage");
    expect(valueFinder, findsOneWidget);
  });

  testWidgets("Fetch: loading", (WidgetTester tester) async {
    client = MockClient();

    when(client!.get(Uri.parse("https://domain.com/get-string")))
        .thenAnswer((_) async {
      await Future.delayed(Duration(seconds: 1));
      return http.Response(fetchResponseText, 200);
    });

    var fetch = Fetch<String?, dynamic>(
        request: requestString,
        builder: (fetchState) {
          if (fetchState.loading == true) {
            return Text(loadingText, textDirection: TextDirection.ltr);
          }

          return Text(fetchState.response!, textDirection: TextDirection.ltr);
        });

    await tester.pumpWidget(fetch);
    var valueFinder = find.text(loadingText);
    expect(valueFinder, findsOneWidget);

    await tester.pump(Duration(seconds: 1));
    valueFinder = find.text(fetchResponseText);
    expect(valueFinder, findsOneWidget);
  });
}
