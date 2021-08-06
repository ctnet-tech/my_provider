import 'package:http/src/client.dart' as _i4;
import 'package:my_provider/index.dart';

import 'product.dart';
import 'product_data.dart';

_i4.Client? _client;

setClient(dynamic client) {
  _client = client;
}

const domain = "domain.com";
const productsPath = "/products";

Future<Product> getProduct(dynamic params) async {
  final response = await _client!
      .get(Uri.parse("https://$domain$productsPath/${params!.productId!}"));

  if (response.statusCode != 200) {
    throw FetchError(httpStatus: response.statusCode, message: response.body);
  }

  var product = ProductFactory.create(response.body);
  return product;
}

Future<Product> postProduct(dynamic params) async {
  final response = await _client!
      .post(Uri.parse("https://$domain$productsPath"), body: params!.body);

  if (response.statusCode != 200) {
    throw FetchError(httpStatus: response.statusCode, message: response.body);
  }

  var product = ProductFactory.create(response.body);
  return product;
}

Future<Product> deleteProduct(dynamic params) async {
  final response = await _client!
      .delete(Uri.parse("https://$domain$productsPath/${params!.productId}"));
  var product = ProductFactory.create(response.body);
  return product;
}
