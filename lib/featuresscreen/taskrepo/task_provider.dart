import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_flow/featuresscreen/taskrepo/task.dart';

final taskProvider =
    NotifierProvider<TaskNotifier, List<TaskModel>>(
  TaskNotifier.new,
);

class TaskNotifier extends Notifier<List<TaskModel>> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User get _user => FirebaseAuth.instance.currentUser!;

  @override
  List<TaskModel> build() {
    _listenTasks();
    return [];
  }

  /// 🔹 Listen to tasks sorted by DUE DATE (earliest → latest)
  void _listenTasks() {
    _db
        .collection('users')
        .doc(_user.uid)
        .collection('tasks')
        .orderBy('dueDate') // ✅ REQUIRED FIX
        .snapshots()
        .listen((snapshot) {
      state = snapshot.docs
          .map((doc) => TaskModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  /// ✅ Add task using task.id as Firestore document ID
  Future<void> addTask(TaskModel task) async {
    await _db
        .collection('users')
        .doc(_user.uid)
        .collection('tasks')
        .doc(task.id)
        .set(task.toMap());
  }

  /// ✅ Update existing task
  Future<void> updateTask(TaskModel task) async {
    await _db
        .collection('users')
        .doc(_user.uid)
        .collection('tasks')
        .doc(task.id)
        .update(task.toMap());
  }

  /// ✅ Delete task
  Future<void> deleteTask(String id) async {
    await _db
        .collection('users')
        .doc(_user.uid)
        .collection('tasks')
        .doc(id)
        .delete();
  }

  /// ✅ Toggle task completion
  Future<void> toggleComplete(String id) async {
    final task = state.firstWhere((t) => t.id == id);

    await _db
        .collection('users')
        .doc(_user.uid)
        .collection('tasks')
        .doc(id)
        .update({
      'isCompleted': !task.isCompleted,
    });
  }
}
