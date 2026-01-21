import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_flow/featuresscreen/homescreen/notification/notification.dart';
import 'package:task_flow/featuresscreen/taskrepo/task.dart';
import 'package:task_flow/featuresscreen/taskrepo/task_provider.dart';

enum BulletMode { none, bullet, number, dash }

class AddEditTaskSheet extends ConsumerStatefulWidget {
  final TaskModel? task;
  const AddEditTaskSheet({super.key, this.task});

  @override
  ConsumerState<AddEditTaskSheet> createState() =>
      _AddEditTaskSheetState();
}

class _AddEditTaskSheetState extends ConsumerState<AddEditTaskSheet> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();

  TaskPriority _priority = TaskPriority.medium;
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  bool _enableReminder = false;

  /// 🔹 Bullet state
  BulletMode _bulletMode = BulletMode.none;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleCtrl.text = widget.task!.title;
      _descCtrl.text = widget.task!.description;
      _priority = widget.task!.priority;
      _date = widget.task!.dueDate;
      _time = TimeOfDay.fromDateTime(widget.task!.dueDate);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  DateTime get _finalDate => DateTime(
        _date.year,
        _date.month,
        _date.day,
        _time.hour,
        _time.minute,
      );

  /// 🔹 Bullet symbol by mode
  String _bulletText() {
    switch (_bulletMode) {
      case BulletMode.bullet:
        return '• ';
      case BulletMode.number:
        return '1. ';
      case BulletMode.dash:
        return '- ';
      case BulletMode.none:
        return '';
    }
  }

  /// ✅ Insert bullet ALWAYS on a new line
  void _insertBullet(BulletMode mode) {
    _bulletMode = mode;

    final text = _descCtrl.text;
    final needsNewLine =
        text.isNotEmpty && !text.endsWith('\n');

    final newText =
        text + (needsNewLine ? '\n' : '') + _bulletText();

    _descCtrl.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  /// ✅ Auto bullet ONLY if a bullet mode is active
  void _handleNewLine(String value) {
    if (!_descCtrl.text.endsWith('\n')) return;

    if (_bulletMode == BulletMode.none) return;

    final newText = _descCtrl.text + _bulletText();

    _descCtrl.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.88,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          children: [
            /// Drag handle
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 14),

            Text(
              widget.task == null ? 'Add Task' : 'Edit Task',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TITLE
                    TextField(
                      controller: _titleCtrl,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        floatingLabelBehavior:
                            FloatingLabelBehavior.always,
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Description',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),

                    /// BULLET TOOLBAR
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.format_list_bulleted),
                            color: Colors.indigo,
                            onPressed: () =>
                                _insertBullet(BulletMode.bullet),
                          ),
                          IconButton(
                            icon: const Icon(Icons.format_list_numbered),
                            color: Colors.indigo,
                            onPressed: () =>
                                _insertBullet(BulletMode.number),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove),
                            color: Colors.indigo,
                            onPressed: () =>
                                _insertBullet(BulletMode.dash),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// DESCRIPTION
                    TextField(
                      controller: _descCtrl,
                      maxLines: 6,
                      textAlignVertical: TextAlignVertical.top,
                      onChanged: _handleNewLine,
                      decoration: InputDecoration(
                        hintText: 'Write task details...',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// DATE & TIME
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              '${_date.day}/${_date.month}/${_date.year}',
                            ),
                            onPressed: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: _date,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (d != null) setState(() => _date = d);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.access_time),
                            label: Text(_time.format(context)),
                            onPressed: () async {
                              final t = await showTimePicker(
                                context: context,
                                initialTime: _time,
                              );
                              if (t != null) setState(() => _time = t);
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// PRIORITY
                    DropdownButtonFormField<TaskPriority>(
                      value: _priority,
                      decoration: InputDecoration(
                        labelText: 'Priority',
                        floatingLabelBehavior:
                            FloatingLabelBehavior.always,
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: TaskPriority.values
                          .map(
                            (p) => DropdownMenuItem(
                              value: p,
                              child: Text(p.name.toUpperCase()),
                            ),
                          )
                          .toList(),
                      onChanged: (p) =>
                          setState(() => _priority = p!),
                    ),

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Enable Reminder'),
                      activeColor: Colors.indigo,
                      value: _enableReminder,
                      onChanged: (v) =>
                          setState(() => _enableReminder = v),
                    ),
                  ],
                ),
              ),
            ),

            /// SAVE BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  if (_titleCtrl.text.trim().isEmpty) return;

                  final notifier =
                      ref.read(taskProvider.notifier);

                  final task = TaskModel(
                    id: widget.task?.id ??
                        DateTime.now()
                            .millisecondsSinceEpoch
                            .toString(),
                    title: _titleCtrl.text.trim(),
                    description: _descCtrl.text.trim(),
                    dueDate: _finalDate,
                    priority: _priority,
                  );

                  widget.task == null
                      ? notifier.addTask(task)
                      : notifier.updateTask(task);

                  if (_enableReminder) {
                    NotificationService.scheduleTaskNotification(
                      id: task.id.hashCode,
                      title: 'Task Reminder',
                      body: task.title,
                      dateTime: _finalDate,
                    );
                  }

                  Navigator.pop(context);
                },
                child: const Text('Save Task'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
