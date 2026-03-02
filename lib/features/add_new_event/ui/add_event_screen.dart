import 'package:events/core/extension/navigator_extension.dart';
import 'package:events/features/add_new_event/cubit/add_event_cubit.dart';
import 'package:events/features/add_new_event/ui/widgets/attachment_widget.dart';
import 'package:events/features/add_new_event/ui/widgets/button_section.dart';
import 'package:events/features/add_new_event/ui/widgets/event_type_selector.dart';
import 'package:events/features/add_new_event/ui/widgets/image_picker.dart';
import 'package:events/features/add_new_event/ui/widgets/tool_selector.dart';
import 'package:events/features/events/model/event_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({this.onAdded, super.key, this.eventToUpdate});
  final void Function(EventModel postedEvent)? onAdded;
  final EventModel? eventToUpdate;

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final TextEditingController _titleTextController = TextEditingController();
  final TextEditingController _descriptionTextController = TextEditingController();

  void _showSnackBarMessage(String msg, {bool success = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green.shade600 : Colors.red.shade600,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    if (widget.eventToUpdate != null) {
      final eventToUpdate = widget.eventToUpdate!;
      _titleTextController.text = eventToUpdate.title;
      _descriptionTextController.text = eventToUpdate.desc;
    }
  }

  @override
  void dispose() {
    _titleTextController.dispose();
    _descriptionTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.eventToUpdate != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'ویرایش محصول' : 'محصول جدید',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[50],
      body: BlocProvider<AddEventCubit>(
        create: (context) => AddEventCubit(widget.eventToUpdate ?? EventModel.empty),
        child: BlocConsumer<AddEventCubit, AddEventState>(
          listener: (context, state) {
            if (state is EventAddingFailed) {
              _showSnackBarMessage(state.message, success: false);
            } else {
              if (state is EventPostingSuccess) {
                _showSnackBarMessage(state.message);
                widget.onAdded?.call(state.eventModel);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.navigatorPop();
                });
              }
            }
          },
          builder: (context, state) {
            final addEventCubit = context.read<AddEventCubit>();
            return Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        spacing: 20,
                        children: [
                          ImagePickerWidget(state.eventModel.imagePaths),
                          _buildTextField(
                            label: 'نام برنامه',
                            icon: Icons.badge_outlined,
                            controller: _titleTextController,
                            hint: 'نام برنامه را وارد کنید',
                          ),
                          EventTypeSelector(eventType: state.eventModel.type),
                          ToolSelector(state.eventModel.tools),
                          AttachmentWidgets(state.eventModel.attachments),
                          _buildTextField(
                            label: 'توضیحات',
                            textType: TextInputType.multiline,
                            icon: Icons.description_outlined,
                            controller: _descriptionTextController,
                            hint: 'توضیحات برنامه (اختیاری)',
                            height: 250,
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child: ButtonSection(
                      title: isEditing ? 'آپدیت برنامه' : 'افزودن برنامه',
                      isPosting: state is EventPosting || state is EventPostingSuccess,
                      onReset: isEditing
                          ? null
                          : () {
                              _titleTextController.clear();
                              _descriptionTextController.clear();
                              addEventCubit.restFrom();
                            },
                      onSubmit: () {
                        addEventCubit.submitForm(
                            title: _titleTextController.text, description: _descriptionTextController.text, isEditing: isEditing);
                      },
                    )),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hint,
    TextInputType? textType,
    double height = 80,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 8),
        SizedBox(
          height: height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: Colors.grey[300]!, width: 2),
            ),
            child: TextField(
              maxLines: textType == TextInputType.multiline ? null : 1,
              controller: controller,
              keyboardType: textType ?? TextInputType.text,
              decoration: InputDecoration(
                hintText: hint,
                prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(7), borderSide: BorderSide.none),
                filled: false,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
