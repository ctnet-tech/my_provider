import 'product.dart';
import 'dart:convert';
class ProductFetchParams {
  ProductFetchParams({this.body, this.productId});

  Product? body;
  int? productId;
}

const productJsonString = '{"id": 1, "name": "cat", "type": "pet"}';
var listProductJsonString =  jsonEncode( List.generate(100, (int index)=>json.decode('{"id": $index, "name": "cat", "type": "pet"}') as Map<String, dynamic>).toList()).toString();

var productData = ProductFactory.create(productJsonString);
var body = Product(name: productData.name, type: productData.type);
var params = ProductFetchParams(body: body, productId: 1);
