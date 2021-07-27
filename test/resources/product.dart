import 'dart:convert';

class ProductFactory {
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

    return product;
  }

  Map<String, dynamic> toJson(Product product) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["id"] = product.id;
    data["name"] = product.name;
    data["type"] = product.type;
    return data;
  }
}

class Product {
  Product({this.name, this.type});

  int? id;
  String? name;
  String? type;
}
