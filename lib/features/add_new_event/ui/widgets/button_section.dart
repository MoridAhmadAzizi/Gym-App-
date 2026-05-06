import 'package:flutter/material.dart';

class ButtonSection extends StatelessWidget {
  const ButtonSection({required this.title, this.onReset, this.onSubmit, this.isPosting = false, super.key});
  final String title;
  final VoidCallback? onReset;
  final VoidCallback? onSubmit;
  final bool isPosting;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.grey.withAlpha(80), blurRadius: 10, offset: const Offset(0, -1)),
        ],
      ),
      child: isPosting
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(5),
                child: CircularProgressIndicator(),
              ),
            )
          : Row(
              spacing: 10,
              children: [
                if (onReset != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReset,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const Text('پاک کردن', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                    ),
                  ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (!isPosting) {
                        onSubmit?.call();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                      backgroundColor: Theme.of(context).primaryColor,
                      elevation: 0,
                    ),
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
