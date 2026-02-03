import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:wahab/model/profile.dart';
import 'package:wahab/services/admin_repo.dart';

part 'users_state.dart';

class UsersCubit extends Cubit<UsersState> {
  UsersCubit(this._repo) : super(const UsersState.loading()) {
    refresh();
  }

  final AdminRepo _repo;

  Future<void> refresh() async {
    emit(const UsersState.loading());
    try {
      final list = await _repo.listUsers();
      emit(UsersState.ready(list));
    } catch (_) {
      emit(const UsersState.error('خطا در دریافت لیست کاربران'));
    }
  }

  Future<void> toggleActive(Profile p) async {
    try {
      await _repo.setActive(userId: p.id, isActive: !p.isActive);
      await refresh();
    } catch (_) {
      emit(const UsersState.error('انجام عملیات موفق نشد'));
      await refresh();
    }
  }

  Future<void> setRole(Profile p, String role) async {
    try {
      await _repo.setRole(userId: p.id, role: role);
      await refresh();
    } catch (_) {
      emit(const UsersState.error('انجام عملیات موفق نشد'));
      await refresh();
    }
  }
}
