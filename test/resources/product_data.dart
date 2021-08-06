import 'product.dart';

class Pagination {
  Pagination(
      {this.page = 1, this.itemPerPage = 20, this.orderBy, this.orderType});
  final int? page;
  final int? itemPerPage;
  final String? orderBy;
  final String? orderType;
}

class ProductFetchParams {
  ProductFetchParams({this.body, this.productId, this.pagination});

  Product? body;
  int? productId;

  Pagination? pagination;
}

const productJsonString = '{"id": 1, "name": "cat", "type": "pet"}';
var productData = ProductFactory.create(productJsonString);
var body = Product(name: productData.name, type: productData.type);
var params = ProductFetchParams(body: body, productId: 1);
