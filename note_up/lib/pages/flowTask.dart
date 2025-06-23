import 'dart:ui';
import 'package:note_up/pages/subtaskItem.dart';
import 'newHome.dart';
import 'package:flutter/material.dart';
import 'package:note_up/pages/newHome.dart';


// Modified FlowTaskItem and other classes
class FlowTaskItem extends StatelessWidget {
  final ProjectTask task;
  final bool isLast;
  final VoidCallback onToggleExpand;
  final VoidCallback onAddSubtask;
  final Function(String) onEditTitle;
  final Function(int, String) onEditSubtask;
  final VoidCallback onDelete;
  final Function(int) onDeleteSubtask;

  const FlowTaskItem({
    super.key,
    required this.task,
    required this.isLast,
    required this.onToggleExpand,
    required this.onAddSubtask,
    required this.onEditTitle,
    required this.onEditSubtask,
    required this.onDelete,
    required this.onDeleteSubtask,
  });
  void showEditDialog(
      BuildContext context,
      String initialText,
      Function(String) onSave,
      ) {
    final controller = TextEditingController(text: initialText);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: const Text('Edit Title'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Title',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 40,
              child: Column(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: task.isExpanded && task.subItems.isNotEmpty
                          ? (task.subItems.length * 50.0) + 80
                          : 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
            ),
            Expanded(
              child: Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: onToggleExpand,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      task.title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    color: Theme.of(context).colorScheme.secondary,
                                    onPressed: () {
                                      showEditDialog(context, task.title, onEditTitle);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20),
                                    color: Theme.of(context).colorScheme.error,
                                    onPressed: onDelete,
                                  ),
                                  Icon(
                                    task.isExpanded
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (task.isExpanded) ...[
                            const Divider(height: 1),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: Column(
                                children: [
                                  ...List.generate(
                                    task.subItems.length,
                                        (index) => SubtaskItem(
                                      title: task.subItems[index],
                                      onEdit: (title) => onEditSubtask(index, title),
                                      onDelete: () => onDeleteSubtask(index),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextButton.icon(
                                      onPressed: onAddSubtask,
                                      icon: const Icon(Icons.add, size: 16),
                                      label: const Text('Add Subtask'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Theme.of(context).colorScheme.secondary,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}