import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task/auth_controllers.dart';
import 'package:task/color_const.dart';

class HomeScreen extends StatelessWidget {
  final AuthController authController = Get.find();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: lightGrey,
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                tileMode: TileMode.decal,
                colors: ColorConstants.linearGradientColor3)),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tasks',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const TaskList(),
              const SizedBox(height: 20),
              TaskForm(),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskList extends StatelessWidget {
  const TaskList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient:
              LinearGradient(colors: ColorConstants.linearGradientColor3)),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              DateTime? deadline = data['deadline'] != null
                  ? (data['deadline'] as Timestamp).toDate()
                  : null;
              bool completed = data['completed'] ?? false;

              return ListTile(
                title: Text(data['title']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['description']),
                    if (deadline != null)
                      Text('Deadline: ${deadline.toString()}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Toggle completion status
                        FirebaseFirestore.instance
                            .collection('tasks')
                            .doc(document.id)
                            .update({
                          'completed': !completed,
                        });
                      },
                      child: Text(completed ? 'Completed' : 'Mark Complete'),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class TaskForm extends StatelessWidget {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController deadlineDateController = TextEditingController();
  final TextEditingController deadlineTimeController = TextEditingController();
  final TextEditingController durationController = TextEditingController();

  DateTime? selectedDeadline;

  TaskForm({super.key});

  Future<void> selectDeadlineDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDeadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 10),
    );
    if (picked != null) {
      selectedDeadline = picked;
      deadlineDateController.text = picked.toString().split(' ')[0];
    }
  }

  Future<void> selectDeadlineTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final DateTime now = DateTime.now();
      final DateTime pickedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );
      selectedDeadline = pickedDateTime;
      deadlineTimeController.text = picked.format(context);
    }
  }

  void submitTask(BuildContext context) {
    if (titleController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection('tasks').add({
        'title': titleController.text,
        'description': descriptionController.text,
        'deadline': selectedDeadline != null
            ? Timestamp.fromDate(selectedDeadline!)
            : null,
        'duration': durationController.text,
        'completed': false,
        'userId': Get.find<AuthController>().auth.currentUser!.uid,
      }).then((value) {
        titleController.clear();
        descriptionController.clear();
        deadlineDateController.clear();
        deadlineTimeController.clear();
        durationController.clear();
        selectedDeadline = null;
        Get.snackbar('Success', 'Task added successfully');
      }).catchError((error) => Get.snackbar('Error', error.toString()));
    } else {
      Get.snackbar('Error', 'Please enter a title for the task');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient:
              LinearGradient(colors: ColorConstants.linearGradientColor3)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Task',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          TextFormField(
            controller: descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: deadlineDateController,
                  decoration: const InputDecoration(labelText: 'Deadline Date'),
                  onTap: () => selectDeadlineDate(context),
                  readOnly: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: deadlineTimeController,
                  decoration: const InputDecoration(labelText: 'Deadline Time'),
                  onTap: () => selectDeadlineTime(context),
                  readOnly: true,
                ),
              ),
            ],
          ),
          TextFormField(
            controller: durationController,
            decoration: const InputDecoration(labelText: 'Expected Duration'),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 130),
            child: TextButton(
              onPressed: () => submitTask(context),
              child: const Text('Add Task'),
            ),
          ),
        ],
      ),
    );
  }
}
