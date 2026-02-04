import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';

import '../controllers/product_controller.dart';
import '../model/product.dart';

class Add extends StatefulWidget {
  final Product? initialProduct;
  const Add({super.key, this.initialProduct});

  @override
  State<Add> createState() => _AddState();
}

class _AddState extends State<Add> {
  final List<String> _tags = [];
  final ImagePicker _picker = ImagePicker();
  List<String> _imagePaths = [];

  String _selectedGroup = 'گروپ اول';
  String _tagInput = '';

  final List<String> _groups = ['گروپ اول', 'گروپ دوم'];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  bool _isSaving = false;

  void _resetForm() {
    _nameController.clear();
    _descriptionController.clear();
    _tagController.clear();
    _tagInput = '';
    _tags.clear();
    _imagePaths = [];
    _selectedGroup = 'گروپ اول';
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isEmpty) return;

    setState(() {
      for (final img in images) {
        final p = img.path;
        if (_imagePaths.length >= 10) break;
        if (!_imagePaths.contains(p)) {
          _imagePaths.add(p);
        }
      }
    });
  }

  void _removeImageAt(int index) {
    setState(() {
      if (index >= 0 && index < _imagePaths.length) {
        _imagePaths.removeAt(index);
      }
    });
  }

  bool _isRemote(String s) => s.startsWith('http://') || s.startsWith('https://');

  Widget _buildImageThumb(String path) {
    final pc = Get.find<ProductController>();

    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.cover);
    }

    if (_isRemote(path)) {
      final cached = pc.cachedBytes(path);
      if (cached != null) {
        return Image.memory(cached, fit: BoxFit.cover);
      }
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
      );
    }

    final normalized = path.startsWith('file://') ? path.replaceFirst('file://', '') : path;

    // ✅ اگر فایل لوکال وجود نداشت، از کش بزن
    if (!File(normalized).existsSync()) {
      final cached = pc.cachedBytes(path);
      if (cached != null) {
        return Image.memory(cached, fit: BoxFit.cover);
      }
      return const Icon(Icons.broken_image);
    }

    return Image.file(
      File(normalized),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
    );
  }

  void _addTag() {
    final t = _tagInput.trim();
    if (t.isEmpty) return;
    if (_tags.contains(t)) return;
    setState(() {
      _tags.add(t);
      _tagController.clear();
      _tagInput = '';
    });
  }

  void _removeTag(int index) {
    setState(() {
      if (index >= 0 && index < _tags.length) _tags.removeAt(index);
    });
  }

  void _showMessage(String msg, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green.shade600 : Colors.red.shade600,
      ),
    );
  }

  Future<void> _saveForm() async {
    if (_isSaving) return;

    final bool isEdit = widget.initialProduct != null;
    final String name = _nameController.text.trim();
    final String desc = _descriptionController.text.trim();

    if (name.isEmpty) {
      _showMessage('لطفاً نام محصول را وارد کنید', success: false);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final String productId = isEdit ? widget.initialProduct!.id : "";

      final product = Product(
        id: productId,
        title: name,
        group: _selectedGroup,
        desc: desc,
        tools: List<String>.from(_tags),
        imagePaths: _imagePaths.isNotEmpty ? List<String>.from(_imagePaths) : const ['assets/images/product.png'],
        createdAt: widget.initialProduct?.createdAt,
        updatedAt: widget.initialProduct?.updatedAt,
      );

      final pc = Get.find<ProductController>();
      await pc.upsert(product);

      if (!mounted) return;
      _showMessage(isEdit ? "محصول موفقانه ویرایش شد!" : "محصول موفقانه اضافه شد!", success: true);
      await Future.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;
      Get.back(result: isEdit ? "updated" : "added");
    } catch (e) {
      if (!mounted) return;
      _showMessage("Failed: $e", success: false);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.initialProduct != null) {
      final p = widget.initialProduct!;
      _nameController.text = p.title;
      _selectedGroup = p.group;

      _tags
        ..clear()
        ..addAll(p.tools);

      _descriptionController.text = p.desc;

      _imagePaths = List<String>.from(p.imagePaths);
      if (_imagePaths.length > 10) {
        _imagePaths = _imagePaths.take(10).toList();
      }
    } else {
      _resetForm();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialProduct != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'ویرایش محصول' : 'محصول جدید',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[50],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildImageCard(),
                    const SizedBox(height: 24),
                    _buildTextField(
                      label: 'نام محصول',
                      icon: Icons.badge_outlined,
                      controller: _nameController,
                      hint: 'نام محصول را وارد کنید',
                    ),
                    const SizedBox(height: 20),
                    _buildGroupSelector(),
                    const SizedBox(height: 20),
                    _buildTagsSection(),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'توضیحات',
                      icon: Icons.description_outlined,
                      controller: _descriptionController,
                      hint: 'توضیحات محصول (اختیاری)',
                      maxLines: 1,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          _buildActionButtons(isEdit: isEdit),
        ],
      ),
    );
  }

  Widget _buildImageCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'عکس ها',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.black87),
              ),
              const Spacer(),
              Text('${_imagePaths.length}/10', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: (_imagePaths.length >= 10) ? null : _pickImages,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                ),
                icon: const Icon(Icons.add_photo_alternate_outlined, size: 18, color: Colors.white),
                label: Text(_imagePaths.isEmpty ? 'انتخاب' : 'افزودن', style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_imagePaths.isEmpty)
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 22),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.cloud_upload_outlined, size: 42, color: Colors.grey),
                    SizedBox(height: 10),
                    Text('حد مجاز برای انتخاب عکس الی 10 عدد.', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 96,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _imagePaths.length,
                separatorBuilder: (_, __) => const SizedBox(width: 0),
                itemBuilder: (context, index) {
                  final path = _imagePaths[index];
                  return Padding(
                    padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
                    child: SizedBox(
                      width: 96,
                      height: 96,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              color: Colors.grey.shade100,
                              child: SizedBox.expand(child: _buildImageThumb(path)),
                            ),
                          ),
                          Positioned(
                            top: -10,
                            right: -10,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _removeImageAt(index),
                                borderRadius: BorderRadius.circular(999),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.65), shape: BoxShape.circle),
                                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: Colors.grey[300]!, width: 2),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(7), borderSide: BorderSide.none),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('گروپ', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: Colors.grey[300]!, width: 2),
          ),
          child: DropdownButton<String>(
            value: _selectedGroup,
            isExpanded: true,
            underline: const SizedBox(),
            icon: const Icon(Icons.expand_more, color: Colors.grey),
            style: const TextStyle(fontSize: 16, color: Colors.black87),
            items: _groups.map((String group) {
              return DropdownMenuItem<String>(
                value: group,
                child: Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(group)),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                setState(() => _selectedGroup = newValue);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ابزار و آلات', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                ),
                child: TextField(
                  controller: _tagController,
                  onChanged: (value) => _tagInput = value,
                  onSubmitted: (_) => _addTag(),
                  decoration: InputDecoration(
                    hintText: 'ابزار مورد نظر را وارد کنید.',
                    prefixIcon: Icon(Icons.tag, color: Theme.of(context).primaryColor),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(7), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(7)),
              child: IconButton(onPressed: _addTag, icon: const Icon(Icons.add, color: Colors.white)),
            ),
          ],
        ),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(_tags.length, (index) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(7)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_tags[index], style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(width: 6),
                    GestureDetector(onTap: () => _removeTag(index), child: Icon(Icons.close, size: 16, color: Colors.grey[900])),
                  ],
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons({required bool isEdit}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.grey.withAlpha(80), blurRadius: 10, offset: const Offset(0, -1)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isSaving
                  ? null
                  : () {
                      setState(() => _resetForm());
                      Get.back(result: 'cancelled');
                    },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: const Text('لغو کردن', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                backgroundColor: Theme.of(context).primaryColor,
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : Text(
                      isEdit ? 'آپدیت محصول' : 'افزودن محصول',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
