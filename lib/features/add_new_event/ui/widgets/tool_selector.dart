import 'package:events/features/add_new_event/cubit/add_event_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ToolSelector extends StatefulWidget {
  const ToolSelector(this.selectedTools, {super.key});
  final List<String> selectedTools;

  @override
  State<ToolSelector> createState() => _ToolSelectorState();
}

class _ToolSelectorState extends State<ToolSelector> {
  late TextEditingController toolTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final addEventCubit = context.read<AddEventCubit>();

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
                  controller: toolTextController,
                  onSubmitted: (toolText) => addEventCubit.addTool(toolText),
                  decoration: InputDecoration(
                    hintText: 'ابزار مورد نظر را وارد کنید',
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
              child: IconButton(
                  onPressed: () {
                    addEventCubit.addTool(toolTextController.text);
                    toolTextController.clear();
                  },
                  icon: const Icon(Icons.add, color: Colors.white)),
            ),
          ],
        ),
        if (widget.selectedTools.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(widget.selectedTools.length, (index) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(999)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.selectedTools[index], style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w800, fontSize: 13)),
                    const SizedBox(width: 6),
                    InkWell(onTap: () => addEventCubit.removeTool(index), child: Icon(Icons.close, size: 16, color: Colors.grey[900])),
                  ],
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
