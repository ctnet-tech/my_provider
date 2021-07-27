import 'product.dart';

class ProductFetchParams {
  ProductFetchParams({this.body, this.productId});

  Product? body;
  int? productId;
}

const productJsonString = '{"id": 1, "name": "cat", "type": "pet"}';
var productData = ProductFactory.create(productJsonString);
var body = Product(name: productData.name, type: productData.type);
var params = ProductFetchParams(body: body);
