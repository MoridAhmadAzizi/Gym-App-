import 'package:flutter/material.dart';
import 'package:wahab/screens/add/add.dart';
import 'package:wahab/model/product.dart';

class Update extends StatelessWidget {
  final Product product;

  const Update({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Add(initialProduct: product);
  }
}
