import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wahab/model/profile.dart';
import 'package:wahab/services/admin_repo.dart';
import 'package:wahab/services/auth_cubit.dart';
import 'package:wahab/services/users_cubit.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  void _snack(BuildContext context, String msg, {bool ok = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: ok ? Colors.green.shade600 : Colors.red.shade600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    if (authState.profile?.isSuperAdmin != true) {
      return const Scaffold(body: Center(child: Text('دسترسی ندارید')));
    }
    final myId = authState.session?.user.id ?? '';

    return BlocProvider(
      create: (_) => UsersCubit(AdminRepo(Supabase.instance.client)),
      child: Scaffold(
        appBar: AppBar(title: const Text('کاربران')),
        body: BlocConsumer<UsersCubit, UsersState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              _snack(context, state.errorMessage!);
            }
          },
          builder: (context, state) {
            if (state.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            final users = state.users;
            if (users.isEmpty) {
              return const Center(child: Text('هیچ کاربری موجود نیست'));
            }

            return RefreshIndicator(
              onRefresh: () => context.read<UsersCubit>().refresh(),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final u = users[i];
                  return _UserCard(u: u, myId: myId);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.u, required this.myId});
  final Profile u;
  final String myId;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<UsersCubit>();
    final isMe = u.id == myId;

    // فقط دو نقش قابل مدیریت از UI: user/admin
    final roleValue = (u.roleNormalized == 'admin') ? 'admin' : 'user';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    u.email,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(u.roleNormalized),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: isMe ? null : () => cubit.toggleActive(u),
                  icon: Icon(u.isActive ? Icons.pause_circle : Icons.play_circle),
                  label: Text(u.isActive ? 'غیر فعال' : 'فعال'),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.security, size: 18),
                    const SizedBox(width: 6),
                    DropdownButton<String>(
                      value: roleValue,
                      items: const [
                        DropdownMenuItem(value: 'user', child: Text('user')),
                        DropdownMenuItem(value: 'admin', child: Text('admin')),
                      ],
                      onChanged: isMe
                          ? null
                          : (v) {
                        if (v == null) return;
                        cubit.setRole(u, v);
                      },
                    ),
                  ],
                ),
                if (isMe)
                  Text(
                    'این حساب شماست (برای جلوگیری از قفل شدن، غیرفعال/تغییر نقش از UI بسته است).',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
