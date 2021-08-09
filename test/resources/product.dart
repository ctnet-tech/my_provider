import 'dart:convert';

abstract class ProductFactory {
  static List<Product> createList(String jsonString) {
    var rawModels = jsonDecode(jsonString) as List;
    var products = rawModels
        .map((rawModel) => ProductFactory._fromJson(rawModel))
        .toList();
    return products;
  }

  static Product create(String jsonString) {
    var json = jsonDecode(jsonString);
    var product = ProductFactory._fromJson(json);
    return product;
  }

  static Product _fromJson(Map<String, dynamic> json) {
    var product = Product();

    if (json["id"] is int) product.id = json["id"];
    if (json["name"] is String) product.name = json["name"];
    if (json["type"] is String) product.type = json["type"];
    if (json["isDeleted"] is String)
      product.isDeleted = json["isDeleted"] == 'true';

    return product;
  }

  static Map<String, dynamic> _productToMap(Product product) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["id"] = product.id;
    data["name"] = product.name;
    data["type"] = product.type;
    data["isDeleted"] = product.isDeleted;

    return data;
  }

  static String toJson(Product product) {
    final Map<String, dynamic> data = _productToMap(product);
    return json.encode(data);
  }

  static String listToJson(List<Product> products) {
    var maps = products.map((product) => _productToMap(product)).toList();
    return json.encode(maps);
  }
}

class Product {
  Product({this.name, this.type});

  int? id;
  String? name;
  String? type;

  bool? isDeleted;
}
