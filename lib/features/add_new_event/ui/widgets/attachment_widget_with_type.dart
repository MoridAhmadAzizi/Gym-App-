import 'package:flutter/material.dart';

class AttachmentWidgetWithType extends StatelessWidget {
  const AttachmentWidgetWithType(this.type, {super.key});
  final String type;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Stack(
      children: [
        const Icon(
          Icons.insert_drive_file_rounded,
          size: 40,
          color: Colors.grey,
        ),
        Positioned.fill(
            child: Center(
                child: Padding(
          padding: const EdgeInsets.only(top: 17),
          child: Text(
            type,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        )))
      ],
    ));
  }
}
