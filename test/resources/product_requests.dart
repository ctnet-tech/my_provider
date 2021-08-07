import 'package:http/src/client.dart' as _i4;
import 'package:my_provider/index.dart';

import 'product.dart';
import 'product_data.dart';

_i4.Client? _client;

setClient(dynamic client) {
  _client = client;
}

Future<Product> getProduct(ProductFetchParams? params) async {
  final response = await _client!
      .get(Uri.parse("https://domain.com/products/${params!.productId!}"));

  if (response.statusCode != 200) {
    throw FetchError(httpStatus: response.statusCode, message: response.body);
  }
  var product = ProductFactory.create(response.body);
  return product;
}
Future<List<Product>> getListProduct(int? page) async {
  final response = await _client!
      .get(Uri.parse("https://domain.com/products/$page"));
  if (response.statusCode != 200) {
    throw FetchError(httpStatus: response.statusCode, message: response.body);
  }
  var products = ProductFactory.createList(response.body);
  return products;
}

Future<Product> postProduct(ProductFetchParams? params) async {
  final response = await _client!
      .post(Uri.parse("https://domain.com/products"), body: params!.body);

  if (response.statusCode != 200) {
    throw FetchError(httpStatus: response.statusCode, message: response.body);
  }

  var product = ProductFactory.create(response.body);
  return product;
}

Future<Product> deleteProduct(ProductFetchParams? params) async {
  final response = await _client!
      .delete(Uri.parse("https://domain.com/products/${params!.body!.id}"));
  var product = ProductFactory.create(response.body);
  return product;
}
