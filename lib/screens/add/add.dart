import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wahab/model/product.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wahab/data/product_data.dart';

class Add extends StatefulWidget {
  final Product? initialProduct;
  const Add({super.key, this.initialProduct});

  @override
  State<Add> createState() => _AddState();
}

class _AddState extends State<Add> {
  final List<String> _tags = [];
  final ImagePicker _picker = ImagePicker();

  String _name = '';
  String _selectedGroup = 'Group A';
  String _tagInput = '';
  String _description = '';
  String _initialId = '';

  final List<String> _groups = ['Group A', 'Group B'];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  Future<void> _pickImages() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image picker would open here'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _addTag() {
    if (_tagInput.trim().isNotEmpty) {
      setState(() {
        _tags.add(_tagInput.trim());
        _tagInput = '';
        _tagController.text = '';
      });
    }
  }

  void _removeTag(int index) {
    setState(() {
      _tags.removeAt(index);
    });
  }

  void _saveForm() {
    _name = _nameController.text.trim();
    _description = _descriptionController.text.trim();

    if (_name.isEmpty) {
      _showMessage('Please enter name');
      return;
    }
    final id = _initialId.isNotEmpty
        ? _initialId
        : DateTime.now().millisecondsSinceEpoch.toString();

    final newProduct = Product(
      id: id,
      title: _name,
      group: _selectedGroup,
      desc: _description,
      tool: List<String>.from(_tags),
      imageURL: ['assets/images/bg1.png'],
    );

    if (widget.initialProduct != null) {
      final idx = products.indexWhere((p) => p.id == id);
      if (idx != -1) {
        products[idx] = newProduct;
      }
      _showMessage('Item updated successfully!');
    } else {
      products.add(newProduct);
      _showMessage('Item added successfully!');
    }

    context.pop();
  }

  void _resetForm() {
    setState(() {
      _name = '';
      _selectedGroup = 'Group A';
      _tags.clear();
      _tagInput = '';
      _description = '';
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.grey.shade600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),

            const SizedBox(height: 32),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildImageCard(),
                    const SizedBox(height: 24),
                    _buildTextField(
                      label: 'Name',
                      icon: Icons.badge_outlined,
                      controller: _nameController,
                      onChanged: (value) => _name = value,
                      hint: 'Enter item name',
                    ),
                    const SizedBox(height: 20),
                    _buildGroupSelector(),
                    const SizedBox(height: 20),
                    _buildTagsSection(),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'Description',
                      icon: Icons.description_outlined,
                      controller: _descriptionController,
                      onChanged: (value) => _description = value,
                      hint: 'Optional description',
                      maxLines: 1,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialProduct != null) {
      final p = widget.initialProduct!;
      _initialId = p.id;
      _name = p.title;
      _selectedGroup = p.group;
      _tags.clear();
      _tags.addAll(p.tool);
      _description = p.desc;
      _nameController.text = _name;
      _descriptionController.text = _description;
      _tagController.text = '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload New Item',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Fill in the details below',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageCard() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_upload_outlined,
                size: 40,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Upload Images',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Click to select multiple images',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Only images allowed',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required Function(String) onChanged,
    TextEditingController? controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7),
              border: BoxBorder.all(color: Colors.grey[300]!, width: 2)),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: Colors.grey),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: BorderSide.none),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
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
        const Text(
          'Group',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: Colors.grey[300]!, width: 2)),
          child: DropdownButton<String>(
            value: _selectedGroup,
            isExpanded: true,
            underline: const SizedBox(),
            icon: const Icon(Icons.expand_more, color: Colors.grey),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            items: _groups.map((String group) {
              return DropdownMenuItem<String>(
                value: group,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(group),
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedGroup = newValue;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  // Tags Section
  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),

        // Input Row
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(7),
                    border: BoxBorder.all(color: Colors.grey[300]!, width: 2)),
                child: TextField(
                  controller: _tagController,
                  onChanged: (value) => _tagInput = value,
                  onSubmitted: (_) => _addTag(),
                  decoration: InputDecoration(
                    hintText: 'Enter tag',
                    prefixIcon: const Icon(Icons.tag, color: Colors.grey),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(7),
                        borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 0,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(7),
              ),
              child: IconButton(
                onPressed: _addTag,
                icon: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),

        // Tags List
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(_tags.length, (index) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _tags[index],
                      style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                          fontSize: 16),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _removeTag(index),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveForm,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
              backgroundColor: Colors.grey,
              elevation: 0,
            ),
            child: Text(
              widget.initialProduct != null ? 'Update Item' : 'Add Item',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
