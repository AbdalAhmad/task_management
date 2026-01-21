import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_flow/featuresscreen/taskrepo/task.dart';
import 'package:task_flow/featuresscreen/taskrepo/task_provider.dart';
import 'package:task_flow/featuresscreen/homescreen/notification/edit_task.dart';
import 'package:task_flow/loginsignupscreen/loginscreen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _darkMode = false;
  TaskPriority? _priorityFilter;
  bool? _statusFilter;

  bool get isDark => _darkMode;

  /// 🎨 Priority color helper
  Color _priorityColor(TaskPriority? p) {
    switch (p) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// 🎨 Status color helper
  Color _statusColor(bool? status) {
    if (status == true) return Colors.green;
    if (status == false) return Colors.red;
    return Colors.grey;
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  void _showSupportMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Support system is coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allTasks = ref.watch(taskProvider);

    final tasks = allTasks.where((task) {
      final priorityMatch =
          _priorityFilter == null || task.priority == _priorityFilter;
      final statusMatch =
          _statusFilter == null || task.isCompleted == _statusFilter;
      return priorityMatch && statusMatch;
    }).toList();

    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';
    final firstLetter = email.isNotEmpty ? email[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF6F7FB),

      /// DRAWER
      drawer: Drawer(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF43CEA2), Color(0xFF185A9D)],
                ),
              ),
              accountName: const Text('TaskFlow'),
              accountEmail: Text(email),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  firstLetter,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SwitchListTile(
              title: Text(
                'Dark Mode',
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
              value: _darkMode,
              onChanged: (v) => setState(() => _darkMode = v),
            ),
            ListTile(
              leading: Icon(Icons.support_agent,
                  color: isDark ? Colors.white : Colors.black),
              title: Text(
                'Support',
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
              onTap: () {
                Navigator.pop(context);
                _showSupportMessage(context);
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title:
                  const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),

      /// APP BAR
      appBar: AppBar(
        centerTitle: true,
        title: const Text('TaskFlow'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF43CEA2), Color(0xFF185A9D)],
            ),
          ),
        ),
      ),

      /// BODY
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome 👋',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: isDark ? Colors.white : Colors.black,
                  ),
            ),

            const SizedBox(height: 16),

            /// 🎨 COLORFUL FILTER BAR
            Row(
              children: [
                /// PRIORITY
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color:
                          _priorityColor(_priorityFilter).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: DropdownButtonFormField<TaskPriority?>(
                      value: _priorityFilter,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        border: InputBorder.none,
                      ),
                      iconEnabledColor:
                          _priorityColor(_priorityFilter),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All'),
                        ),
                        ...TaskPriority.values.map(
                          (p) => DropdownMenuItem(
                            value: p,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 6,
                                  backgroundColor: _priorityColor(p),
                                ),
                                const SizedBox(width: 8),
                                Text(p.name.toUpperCase()),
                              ],
                            ),
                          ),
                        ),
                      ],
                      onChanged: (v) =>
                          setState(() => _priorityFilter = v),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                /// STATUS
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: _statusColor(_statusFilter).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: DropdownButtonFormField<bool?>(
                      value: _statusFilter,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: InputBorder.none,
                      ),
                      iconEnabledColor: _statusColor(_statusFilter),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('All')),
                        DropdownMenuItem(
                            value: false, child: Text('Incomplete')),
                        DropdownMenuItem(
                            value: true, child: Text('Completed')),
                      ],
                      onChanged: (v) =>
                          setState(() => _statusFilter = v),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              'Your Tasks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: tasks.isEmpty
                  ? const Center(child: Text('Press + to add a task'))
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (_, i) =>
                          _SwipeTaskTile(task: tasks[i], isDark: isDark),
                    ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF43CEA2),
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => const AddEditTaskSheet(),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// 🔥 TASK TILE
class _SwipeTaskTile extends ConsumerWidget {
  final TaskModel task;
  final bool isDark;

  const _SwipeTaskTile({required this.task, required this.isDark});

  Color _priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(taskProvider.notifier).deleteTask(task.id);
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => AddEditTaskSheet(task: task),
            );
          },
          leading: Checkbox(
            value: task.isCompleted,
            onChanged: (_) =>
                ref.read(taskProvider.notifier).toggleComplete(task.id),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration:
                  task.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(task.description),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _priorityColor(task.priority).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              task.priority.name.toUpperCase(),
              style: TextStyle(
                color: _priorityColor(task.priority),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
