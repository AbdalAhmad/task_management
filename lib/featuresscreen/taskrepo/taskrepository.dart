import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_flow/featuresscreen/taskrepo/task.dart';

class TaskRepository {
  Future<void> addTask(TaskModel task) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("❌ User not logged in");
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .add(task.toMap());

    print("✅ Task saved for UID: ${user.uid}");
  }
}
