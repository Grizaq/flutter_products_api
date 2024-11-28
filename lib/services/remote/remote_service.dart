import 'package:flutter_products_api/models/products.dart';
import 'package:http/http.dart' as http;

class RemoteService {
  Future<Products?> getProducts() async {
    var client = http.Client();
    var uri = Uri.parse('https://dummyjson.com/products');
    var response = await client.get(uri);
    if (response.statusCode == 200) {
      var json = response.body;
      return productsFromJson(json);
    }
  }
}