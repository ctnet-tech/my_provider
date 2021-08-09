import 'product.dart';

class ProductFetchParams {
  ProductFetchParams({this.body, this.productId,this.page,this.pageAmount=10});

  Product? body;
  int? productId;
  int? page;
  int pageAmount;
}

const productJsonString = '{"id": 1, "name": "cat", "type": "pet"}';
const listProductJsonString = '[{"id": 1, "name": "cat", "type": "pet"}]';
var productData = ProductFactory.create(productJsonString);
var body = Product(name: productData.name, type: productData.type);
var params = ProductFetchParams(body: body, productId: 1);
