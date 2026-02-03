import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wahab/model/product.dart';
import 'package:wahab/services/auth_cubit.dart';
import 'package:wahab/services/date_utils.dart';
import 'package:wahab/services/product_cubit.dart';

class Detail extends StatelessWidget {
  final Product product;
  const Detail({super.key, required this.product});

  bool _isRemote(String s) => s.startsWith('http://') || s.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    final pState = context.watch<ProductCubit>().state;
    final aState = context.watch<AuthCubit>().state;
    final role = aState.profile?.role ?? 'user';
    final canEdit = (role == 'admin' || role == 'super_admin');

    final created = product.createdAt;
    final updated = product.updatedAt;
    final showEdited = updated != null && (created == null || updated.isAfter(created));

    return Scaffold(
      appBar: AppBar(title: const Text('جزئیات محصول')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildImages(context, pState.isOnline),
          const SizedBox(height: 12),
          Text(product.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _chip(context, 'گروه: ${product.group}'),
              if (created != null) _chip(context, 'ایجاد: ${DateUtilsFa.timeHm(created)}'),
              if (showEdited) _chip(context, 'آخرین ویرایش: ${DateUtilsFa.dateYmd(updated!)} - ${DateUtilsFa.timeHm(updated)}'),
            ],
          ),
          const SizedBox(height: 12),
          Text(product.desc, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 18),
          Text('ابزارها', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          if (product.tool.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: product.tool.map((t) => _toolCard(context, t)).toList(),
            )
          else
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(child: Text('هیچ ابزاری اضافه نشده است.')),
            ),
        ],
      ),
      bottomNavigationBar: canEdit
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  onPressed: () {
                    if (!pState.isOnline) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('برای ویرایش باید آنلاین باشید.'),
                          backgroundColor: Colors.red.shade600,
                        ),
                      );
                      return;
                    }
                    context.push('/add', extra: product);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('ویرایش'),
                ),
              ),
            )
          : null,
    );
  }

  Widget _chip(BuildContext context, String t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(t, style: Theme.of(context).textTheme.bodySmall),
    );
  }

  Widget _toolCard(BuildContext context, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer)),
    );
  }

  Widget _buildImages(BuildContext context, bool isOnline) {
    final imgs = product.imageURL.where((e) => e.isNotEmpty).toList();
    if (imgs.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset('assets/images/product.png', height: 220,width: MediaQuery.of(context).size.width, fit: BoxFit.cover),
      );
    }

    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: imgs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 0),
        itemBuilder: (context, i) {
          final img = imgs[i];
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: MediaQuery.of(context).size.width,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: _imageWidget(context, img, isOnline),
            ),
          );
        },
      ),
    );
  }

  Widget _imageWidget(BuildContext context, String img, bool isOnline) {
    if (img.startsWith('assets/')) {
      return Image.asset(img, fit: BoxFit.cover);
    }
    if (_isRemote(img)) {
      if (isOnline) {
        return Image.network(img, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image));
      }
      final bytes = context.read<ProductCubit>().cachedBytes(img);
      if (bytes != null) {
        return Image.memory(bytes, fit: BoxFit.cover);
      }
      return const Center(child: Icon(Icons.image_not_supported));
    }
    final normalized = img.startsWith('file://') ? img.replaceFirst('file://', '') : img;
    final f = File(normalized);
    if (f.existsSync()) {
      return Image.file(f, fit: BoxFit.cover);
    }
    return const Center(child: Icon(Icons.image_not_supported));
  }
}
