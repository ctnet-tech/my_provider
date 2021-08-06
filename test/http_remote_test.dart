import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:my_provider/index.dart';
import 'package:http/http.dart' as http;

import 'http_remote_test.mocks.dart';
import 'resources/product.dart';
import 'resources/product_data.dart';
import 'resources/product_requests.dart';

Uri getUri(String path, dynamic params) {
  var queryParameters = Map<String, dynamic>();

  if (params != null) {
    if (params.pagination is Pagination) {
      var pagination = params.pagination as Pagination;

      queryParameters['page'] = pagination.page?.toString();
      queryParameters['itemPerPage'] = pagination.itemPerPage?.toString();
      queryParameters['orderBy'] = pagination.orderBy?.toString();
      queryParameters['orderType'] = pagination.orderType?.toString();
    }
  }

  return Uri(
      scheme: "https",
      host: domain,
      path: path,
      queryParameters: queryParameters);
}

@GenerateMocks([http.Client])
main() {
  final headers = Map<String, String>();
  headers["Authorization"] = "Bearer some_jwt_token";

  final fetchParams = ProductFetchParams(pagination: Pagination(page: 2));
  final uri = getUri(productsPath, fetchParams);

  test("Remote: createRequest should working correctly", () async {
    final client = MockClient();

    when(client.get(uri, headers: headers)).thenAnswer((_) async {
      await Future.delayed(Duration(seconds: 1));
      return http.Response("[]", 200);
    });

    final remote = new HttpRemote(
        name: 'domains.com',
        client: client,
        getUri: getUri,
        getHeaders: () async {
          return headers;
        });

    final getProducts = remote.createRequest<List<Product>, ProductFetchParams>(
        (client, getUri, getHeaders) {
      return (ProductFetchParams params) async {
        final uri = getUri(productsPath, params);
        final headers = await getHeaders();

        final response = await client.get(uri, headers: headers);

        if (response.statusCode != 200) {
          throw FetchError(
              httpStatus: response.statusCode, message: response.body);
        }

        return <Product>[];
      };
    });

    final result = await getProducts(fetchParams);

    expect(result, []);
  });

  test("Remote: onError should working correctly", () async {
    FetchError catchedError = FetchError(httpStatus: 200, message: "OK");

    final client = MockClient();

    when(client.get(uri, headers: headers)).thenAnswer((_) async {
      await Future.delayed(Duration(seconds: 1));
      return http.Response("NOT_FOUND", 404);
    });

    final remote = new HttpRemote(
        name: 'domains.com',
        client: client,
        getUri: getUri,
        getHeaders: () async {
          return headers;
        },
        onError: (error) {
          if (error is FetchError) {
            catchedError = error;
          }

          throw error;
        });

    final getProducts = remote.createRequest<List<Product>, ProductFetchParams>(
        (client, getUri, getHeaders) {
      return (ProductFetchParams params) async {
        final uri = getUri(productsPath, params);
        final headers = await getHeaders();

        final response = await client.get(uri, headers: headers);

        if (response.statusCode != 200) {
          throw FetchError(
              httpStatus: response.statusCode, message: response.body);
        }

        return <Product>[];
      };
    });

    try {
      await getProducts(fetchParams);
    } on FetchError catch (error) {
      expect(error, catchedError);
      expect(error.httpStatus, 404);
      expect(error.message, "NOT_FOUND");
    }
  });
}
