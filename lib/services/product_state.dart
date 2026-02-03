part of 'product_cubit.dart';

class ProductState extends Equatable {
  final List<Product> products;
  final bool isOnline;

  const ProductState({required this.products, required this.isOnline});

  const ProductState.initial() : this(products: const [], isOnline: true);

  ProductState copyWith({List<Product>? products, bool? isOnline}) {
    return ProductState(
      products: products ?? this.products,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  @override
  List<Object?> get props => [products, isOnline];
}
