import 'product.dart';

class Pagination {
  Pagination(this.page, {this.itemPerPage = 20, this.orderBy, this.orderType});
  final int? page;
  final int? itemPerPage;
  final String? orderBy;
  final String? orderType;
}

class ProductFetchParams {
  ProductFetchParams({this.body, this.productId, this.pagi});

  Product? body;
  int? productId;

  Pagination? pagi;
}

final productJsonPage1 = ProductFactory.listToJson(ProductFactory.createList(
    '[{"id": 1, "name": "cat", "type": "pet"}, {"id": 2, "name": "dog", "type": "pet"}]'));
final productJsonPage2 = ProductFactory.listToJson(ProductFactory.createList(
    '[{"id": 11, "name": "fish", "type": "pet"}, {"id": 12, "name": "rat", "type": "pet"}]'));
final productJsonPage3 = ProductFactory.listToJson(ProductFactory.createList(
    '[{"id": 21, "name": "ant", "type": "pet"}, {"id": 22, "name": "elephants", "type": "pet"}]'));

const productJsonString = '{"id": 1, "name": "cat", "type": "pet"}';
var productData = ProductFactory.create(productJsonString);
var body = Product(name: productData.name, type: productData.type);
var params = ProductFetchParams(body: body, productId: 1);
