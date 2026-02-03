import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:wahab/model/product.dart';
import 'package:wahab/services/auth_cubit.dart';
import 'package:wahab/services/product_cubit.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // 0: همه، 1: گروپ اول، 2: گروپ دوم، 3: افزودن
  int _tabIndex = 0;

  final TextEditingController _searchCtrl = TextEditingController();

  // اگر اسم گروپ‌ها در دیتای شما متفاوت است، این دو را تغییر بده
  static const String group1Name = 'گروپ اول';
  static const String group2Name = 'گروپ دوم';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool ok = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: ok ? Colors.green.shade600 : Colors.red.shade600,
      ),
    );
  }

  void _onTabTap({
    required int index,
    required bool isOnline,
    required bool canEdit,
  }) {
    // Add Tab
    if (index == 3) {
      if (!canEdit) {
        _snack('شما اجازه افزودن/ویرایش ندارید.');
        return;
      }
      if (!isOnline) {
        _snack('برای افزودن/ویرایش باید آنلاین باشید.');
        return;
      }
      // به صفحه افزودن برو و تب قبلی را نگه دار
      context.push('/add');
      return;
    }

    setState(() => _tabIndex = index);
  }

  List<Product> _applyFilters(List<Product> all) {
    final q = _searchCtrl.text.trim().toLowerCase();

    // فیلتر گروپ
    List<Product> filtered = all;
    if (_tabIndex == 1) {
      filtered = all.where((p) => (p.group).trim() == group1Name).toList();
    } else if (_tabIndex == 2) {
      filtered = all.where((p) => (p.group).trim() == group2Name).toList();
    }

    // جستجو (روی عنوان + گروپ + توضیح اگر داشته باشی)
    if (q.isNotEmpty) {
      filtered = filtered.where((p) {
        final title = p.title.toLowerCase();
        final group = p.group.toLowerCase();
        // اگر در مدل شما description وجود دارد، این خط را فعال کن:
        // final desc = (p.description ?? '').toLowerCase();
        // return title.contains(q) || group.contains(q) || desc.contains(q);

        return title.contains(q) || group.contains(q);
      }).toList();
    }

    return filtered;
  }

  String _tabTitle() {
    switch (_tabIndex) {
      case 1:
        return group1Name;
      case 2:
        return group2Name;
      default:
        return 'همه محصولات';
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthCubit>().state;
    final role = auth.profile?.role ?? 'user';
    final canEdit = role == 'admin' || role == 'super_admin';

    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, pState) {
        final isOnline = pState.isOnline;
        final products = _applyFilters(pState.products);

        return Scaffold(
          appBar: AppBar(
            title: const Text('لیست محصولات'),
          ),
          drawer: const _NavigationDrawer(),
          body: SafeArea(
            child: Column(
              children: [
                // --- معرفی برنامه (۲ خط کوچک) + سرچ ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'به برنامه مدیریت کالا خوش آمدید.\nدر تب‌ها فیلتر کنید و داخل همان تب جستجو انجام دهید.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              height: 1.4,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withAlpha(190),
                            ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _searchCtrl,
                        onChanged: (_) => setState(() {}),
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'جستجو در کارت‌ها...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchCtrl.text.trim().isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    setState(() {});
                                  },
                                ),
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withAlpha(120),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(width: 2, color: Colors.grey[300]!)
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(width: 2, color: Colors.grey[300]!)
                          )
                        ),
                      ),
                      const SizedBox(height: 8),

                      // وضعیت آنلاین/آفلاین کوچک
                      Row(
                        children: [
                          Icon(
                            isOnline ? Icons.wifi : Icons.wifi_off,
                            size: 16,
                            color: isOnline
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isOnline ? 'آنلاین' : 'آفلاین',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: isOnline
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const Spacer(),
                          if (!canEdit)
                            Text(
                              'فقط مشاهده',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withAlpha(160),
                                  ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // --- لیست ---
                Expanded(
                  child: products.isEmpty
                      ?
                  SizedBox(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 10,
                          children: [
                            Image.asset(
                              "assets/images/data.png",
                              width: double.infinity,
                              height: 250,
                              fit: BoxFit.cover,
                            ),
                            const Text(
                              'هیچ محصولی موجود نیست.',
                              style: TextStyle(fontSize: 15),
                            )
                          ],
                        ),
                      )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          itemCount: products.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final product = products[i];
                            return _ProductCard(product: product);
                          },
                        ),
                ),
              ],
            ),
          ),

          // --- Bottom Navigation ---
          bottomNavigationBar: BottomNavigationBar(
            currentIndex:
                _tabIndex.clamp(0, 2), // تب Add را "انتخاب‌شده" نشان نمی‌دهیم
            onTap: (i) =>
                _onTabTap(index: i, isOnline: isOnline, canEdit: canEdit),
            type: BottomNavigationBarType.fixed,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.view_list),
                label: 'همه',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.filter_alt),
                label: group1Name,
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.filter_alt_outlined),
                label: group2Name,
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  canEdit
                      ? (isOnline ? Icons.add_circle : Icons.lock)
                      : Icons.lock,
                ),
                label: 'افزودن',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final pState = context.watch<ProductCubit>().state;

    final image =
        (product.imageURL.isNotEmpty && product.imageURL.first.isNotEmpty)
            ? product.imageURL.first
            : 'assets/images/product.png';

    return InkWell(
      onTap: () => context.push('/detail', extra: product),
      borderRadius: BorderRadius.circular(14),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,

                  ),
                  width: 56,
                  height: 56,
                  child: _Thumb(image: image, isOnline: pState.isOnline),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.group,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.image, required this.isOnline});
  final String image;
  final bool isOnline;

  bool _isRemote(String s) =>
      s.startsWith('http://') || s.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    if (image.startsWith('assets/')) {
      return Image.asset(image, fit: BoxFit.cover);
    }

    if (_isRemote(image)) {
      if (isOnline) {
        return Image.network(
          image,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.image),
        );
      }

      final bytes = context.read<ProductCubit>().cachedBytes(image);
      if (bytes != null) {
        return Image.memory(bytes, fit: BoxFit.cover);
      }
      return const Icon(Icons.image_not_supported);
    }

    // local file path
    final normalized =
        image.startsWith('file://') ? image.replaceFirst('file://', '') : image;
    final f = File(normalized);
    if (f.existsSync()) {
      return Image.file(f, fit: BoxFit.cover);
    }
    return const Icon(Icons.image_not_supported);
  }
}

class _NavigationDrawer extends StatelessWidget {
  const _NavigationDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const SizedBox(height: 8),
            Expanded(child: _buildMenu(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final state = context.watch<AuthCubit>().state; // AppAuthState
    final email = state.session?.user.email ?? '';
    final role = state.profile?.role ?? 'user';

    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.primary,
      child: Row(
        children: [
          const CircleAvatar(
            radius: 26,
            backgroundImage: AssetImage('assets/images/product.png'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wahab',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color:
                        Theme.of(context).colorScheme.onPrimary.withAlpha(220),
                  ),
                ),
                Text(
                  'Role: $role',
                  style: TextStyle(
                    color:
                        Theme.of(context).colorScheme.onPrimary.withAlpha(220),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    final authState = context.watch<AuthCubit>().state; // AppAuthState
    final role = authState.profile?.role ?? 'user';
    final canSeeUsers = role == 'super_admin';

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        if (canSeeUsers)
          ListTile(
            leading: const Icon(Icons.supervisor_account),
            title: const Text('کاربران'),
            onTap: () {
              Navigator.pop(context);
              context.push('/users');
            },
          ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('خروج'),
          onTap: () async {
            Navigator.pop(context);
            await context.read<AuthCubit>().signOut();
          },
        ),
      ],
    );
  }
}
