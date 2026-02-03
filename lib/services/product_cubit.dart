import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:wahab/model/product.dart';
import 'package:wahab/services/product_repo.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  ProductCubit(this._repo) : super(const ProductState.initial()) {
    _sub = _repo.watchProducts().listen((list) {
      emit(state.copyWith(products: list));
    });
    _onlineListener = _emitOnline;
    _repo.isOnline.addListener(_onlineListener);
    _emitOnline();
  }

  final ProductRepo _repo;
  StreamSubscription<List<Product>>? _sub;
  late final VoidCallback _onlineListener;

  void _emitOnline() {
    emit(state.copyWith(isOnline: _repo.isOnline.value));
  }

  Uint8List? cachedBytes(String url) => _repo.getCachedBytes(url);

  @override
  Future<void> close() async {
    await _sub?.cancel();
    _repo.isOnline.removeListener(_onlineListener);
    return super.close();
  }
}
