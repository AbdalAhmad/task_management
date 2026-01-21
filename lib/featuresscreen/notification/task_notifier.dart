import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_flow/featuresscreen/taskrepo/task.dart';

final taskProvider =
    NotifierProvider<TaskNotifier, List<TaskModel>>(TaskNotifier.new);

class TaskNotifier extends Notifier<List<TaskModel>> {
  final _db = FirebaseFirestore.instance;

  User get _user => FirebaseAuth.instance.currentUser!;

  @override
  List<TaskModel> build() {
    _listenTasks();
    return [];
  }

  void _listenTasks() {
    _db
        .collection('users')
        .doc(_user.uid)
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      state = snapshot.docs
          .map((doc) => TaskModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<void> addTask(TaskModel task) async {
    await _db
        .collection('users')
        .doc(_user.uid)
        .collection('tasks')
        .add(task.toMap());
  }

  Future<void> updateTask(TaskModel task) async {
    await _db
        .collection('users')
        .doc(_user.uid)
        .collection('tasks')
        .doc(task.id)
        .update(task.toMap());
  }

  Future<void> deleteTask(String id) async {
    await _db
        .collection('users')
        .doc(_user.uid)
        .collection('tasks')
        .doc(id)
        .delete();
  }

  Future<void> toggleComplete(String id) async {
    final task = state.firstWhere((t) => t.id == id);

    await _db
        .collection('users')
        .doc(_user.uid)
        .collection('tasks')
        .doc(id)
        .update({'isCompleted': !task.isCompleted});
  }
}
