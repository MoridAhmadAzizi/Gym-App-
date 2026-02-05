// lib/screens/home.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/product_controller.dart';
import '../model/product.dart';
import 'add.dart';
import 'detail.dart';
import 'login_or_register.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // 0: همه، 1: گروپ اول، 2: گروپ دوم، 3: افزودن
  int _tabIndex = 0;

  final TextEditingController _searchCtrl = TextEditingController();

  static const String group1Name = 'گروپ اول';
  static const String group2Name = 'گروپ دوم';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showOfflineMsg() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('شما افلاین هستید ، اتصال خود را بررسی کنید'),
        backgroundColor: Colors.red.shade600,
      ),
    );
  }

  void _onTabTap(int index) {
    final pc = Get.find<ProductController>();

    if (index == 3) {
      if (!pc.isOnline.value) {
        _showOfflineMsg();
        return;
      }
      Get.to(() => const Add());
      return;
    }

    setState(() => _tabIndex = index);
  }

  List<Product> _applyFilters(List<Product> all) {
    final q = _searchCtrl.text.trim().toLowerCase();

    List<Product> filtered = all;
    if (_tabIndex == 1) {
      filtered = all.where((p) => p.group.trim() == group1Name).toList();
    } else if (_tabIndex == 2) {
      filtered = all.where((p) => p.group.trim() == group2Name).toList();
    }

    if (q.isNotEmpty) {
      filtered = filtered.where((p) {
        final t = p.title.toLowerCase();
        final g = p.group.toLowerCase();
        final d = p.desc.toLowerCase();
        return t.contains(q) || g.contains(q) || d.contains(q);
      }).toList();
    }

    return filtered;
  }

  Future<void> _logout() async {
    final ac = Get.find<AuthController>();

    try {
      await ac.signOut();
      Get.offAll(() => const LoginOrRegister());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('شما موفقانه از حساب خویش خارج شدید!'),
          backgroundColor: Colors.green.shade600,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطا در خروج از سیستم!'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pc = Get.find<ProductController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('صفحه محصولات'),
        actions: [
          // ✅ Logout بالا در AppBar
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),

          // Online/Sync icon
          Obx(() {
            return IconButton(
              onPressed: pc.forceSync,
              icon:
                  Icon(pc.isOnline.value ? Icons.cloud_sync : Icons.cloud_off),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'جستجو...',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          _tabs(),
          const SizedBox(height: 6),
          Expanded(
            child: Obx(() {
              final list = _applyFilters(pc.products);
              if (list.isEmpty) {
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Center(
                      child: Column(
                    children: [
                      Image.asset(
                        'assets/images/data.png',
                        width: MediaQuery.of(context).size.width,
                        height: 290,
                      ),
                      const Text(
                        'چیزی پیدا نشد ، کلمه دیگری را جستجو کنید!',
                        style: TextStyle(fontSize: 16),
                      )
                    ],
                  )),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final p = list[i];
                  return _ProductCard(product: p);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _tabs() {
    Widget tab(String text, int index, {IconData? icon}) {
      final selected = _tabIndex == index;
      return Expanded(
        child: InkWell(
          onTap: () => _onTabTap(index),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon,
                      size: 18,
                      color: selected ? Colors.white : Colors.black87),
                  const SizedBox(width: 6),
                ],
                Text(
                  text,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          tab('همه', 0),
          const SizedBox(width: 8),
          tab(group1Name, 1),
          const SizedBox(width: 8),
          tab(group2Name, 2),
          const SizedBox(width: 8),
          tab('افزودن', 3, icon: Icons.add),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});
  final Product product;

  bool _isRemote(String s) =>
      s.startsWith('http://') || s.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    final pc = Get.find<ProductController>();
    final first = product.imagePaths.isEmpty ? '' : product.imagePaths.first;

    Widget thumb() {
      if (first.isEmpty) {
        return const Icon(Icons.image, size: 40);
      }

      if (first.startsWith('assets/')) {
        return Image.asset(first, fit: BoxFit.cover);
      }

      if (_isRemote(first)) {
        final cached = pc.cachedBytes(first);
        if (cached != null) return Image.memory(cached, fit: BoxFit.cover);
        return Image.network(first,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));
      }

      final normalized = first.startsWith('file://')
          ? first.replaceFirst('file://', '')
          : first;

      if (!File(normalized).existsSync()) {
        final cached = pc.cachedBytes(first);
        if (cached != null) return Image.memory(cached, fit: BoxFit.cover);
        return const Icon(Icons.broken_image);
      }

      return Image.file(File(normalized),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));
    }

    return InkWell(
      onTap: () => Get.to(() => Detail(product: product)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                  border: Border.all(
                      width: 1, color: Theme.of(context).primaryColor),
                  borderRadius: BorderRadius.circular(8)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: SizedBox(width: 65, height: 65, child: thumb()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.title,
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(product.group,
                      style: TextStyle(color: Colors.grey.shade700)),
                ],
              ),
            ),
            const Icon(Icons.chevron_left),
          ],
        ),
      ),
    );
  }
}
