import 'package:flutter/foundation.dart';
import 'package:wahab/data/product_data.dart';
import 'package:wahab/model/product.dart';

class ProductProvider with ChangeNotifier {
  late List<Product> _products;

  ProductProvider() {
    _products = List.from(products);
  }

  List<Product> get products => _products;

  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
  }

  void updateProduct(Product updatedProduct) {
    int index = _products.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      _products[index] = updatedProduct;
      notifyListeners();
    }
  }

  void deleteProduct(String id) {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}
