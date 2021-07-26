import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:my_provider/index.dart';
import 'package:http/http.dart' as http;

import 'fetch_test.mocks.dart';

const fetchResponseText = 'RESPONSE';

MockClient? client;

request() async {
  final response = await client!.get(Uri.parse("https://domain.com/get-data"));
  return response.body;
}

@GenerateMocks([http.Client])
main() {
  testWidgets("Fetch: basic usage", (WidgetTester tester) async {
    client = MockClient();

    when(client!.get(Uri.parse("https://domain.com/get-data")))
        .thenAnswer((_) async {
      await Future.delayed(Duration(seconds: 1));
      return http.Response(fetchResponseText, 200);
    });

    var fetch = Fetch<String?>(
        request: request,
        builder: (response) {
          if (response == null) {
            return Text("NULL", textDirection: TextDirection.ltr);
          }
          return Text(response, textDirection: TextDirection.ltr);
        });

    await tester.pumpWidget(fetch);
    await tester.pump(Duration(seconds: 1));
    var valueFinder = find.text(fetchResponseText);
    expect(valueFinder, findsOneWidget);
  });
}
