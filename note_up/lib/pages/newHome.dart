import 'package:flutter/material.dart';
import 'package:note_up/pages/savedProjectList.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'backgroundPainter.dart';
import 'flowTask.dart';

class Project {
  final String id;
  final String name;
  final List<ProjectTask> tasks;

  Project({required this.id, required this.name, required this.tasks});

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'tasks': tasks.map((task) => task.toJson()).toList(),
  };

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    id: json['id'],
    name: json['name'],
    tasks:
        (json['tasks'] as List)
            .map((task) => ProjectTask.fromJson(task))
            .toList(),
  );
}

class ProjectTrackerPage extends StatefulWidget {
  const ProjectTrackerPage({super.key, required Project initialProject});

  @override
  State<ProjectTrackerPage> createState() => ProjectTrackerPageState();
}

class ProjectTrackerPageState extends State<ProjectTrackerPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  List<ProjectTask> tasks = [];
  String projectName = 'New Project';
  String projectId = DateTime.now().millisecondsSinceEpoch.toString();
  bool isEditing = false;
  TextEditingController projectNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    projectNameController.text = projectName;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    projectNameController.dispose();
    super.dispose();
  }



  Future<void> saveProject() async {
    if (projectName.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project name cannot be empty')),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> savedProjects = prefs.getStringList('projects') ?? [];

      final project = Project(id: projectId, name: projectName, tasks: tasks);

      final projectJson = jsonEncode(project.toJson());

      // Update or add project
      final existingIndex = savedProjects.indexWhere((p) {
        final decoded = jsonDecode(p);
        return decoded['id'] == projectId;
      });

      if (existingIndex >= 0) {
        savedProjects[existingIndex] = projectJson;
      } else {
        savedProjects.add(projectJson);
      }

      await prefs.setStringList('projects', savedProjects);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving project: $e')));
    }
  }

  void toggleExpand(String taskId) {
    setState(() {
      final index = tasks.indexWhere((task) => task.id == taskId);
      if (index != -1) {
        tasks[index] = tasks[index].copyWith(
          isExpanded: !tasks[index].isExpanded,
        );
      }
    });
  }

  void addTask() {
    setState(() {
      tasks.add(
        ProjectTask(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'New Task',
          subItems: [],
          isExpanded: false,
        ),
      );
    });
  }

  void addSubtask(String taskId) {
    setState(() {
      final index = tasks.indexWhere((task) => task.id == taskId);
      if (index != -1) {
        final updatedSubItems = List<String>.from(tasks[index].subItems)
          ..add('New Subtask');
        tasks[index] = tasks[index].copyWith(subItems: updatedSubItems);
      }
    });
  }

  void editTaskTitle(String taskId, String newTitle) {
    if (newTitle.trim().isEmpty) return;
    setState(() {
      final index = tasks.indexWhere((task) => task.id == taskId);
      if (index != -1) {
        tasks[index] = tasks[index].copyWith(title: newTitle);
      }
    });
  }

  void editSubtaskTitle(String taskId, int subtaskIndex, String newTitle) {
    if (newTitle.trim().isEmpty) return;
    setState(() {
      final taskIndex = tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        final updatedSubItems = List<String>.from(tasks[taskIndex].subItems);
        updatedSubItems[subtaskIndex] = newTitle;
        tasks[taskIndex] = tasks[taskIndex].copyWith(subItems: updatedSubItems);
      }
    });
  }

  void deleteTask(String taskId) {
    setState(() {
      tasks.removeWhere((task) => task.id == taskId);
    });
  }

  void deleteSubtask(String taskId, int subtaskIndex) {
    setState(() {
      final taskIndex = tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        final updatedSubItems = List<String>.from(tasks[taskIndex].subItems);
        updatedSubItems.removeAt(subtaskIndex);
        tasks[taskIndex] = tasks[taskIndex].copyWith(subItems: updatedSubItems);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Project Tracker'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Project',
            onPressed: saveProject,
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'View Projects',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SavedProjectsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Positioned.fill(
          //   child: CustomPaint(painter: BackgroundPatternPainter()),
          // ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child:
                                isEditing
                                    ? TextField(
                                      controller: projectNameController,
                                      decoration: InputDecoration(
                                        border: const OutlineInputBorder(),
                                        labelText: 'Project Name',
                                        errorText:
                                            projectNameController.text
                                                    .trim()
                                                    .isEmpty
                                                ? 'Name cannot be empty'
                                                : null,
                                      ),
                                      onChanged: (value) {
                                        setState(() {});
                                      },
                                    )
                                    : Text(
                                      projectName,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineMedium?.copyWith(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                      ),
                                    ),
                          ),
                          IconButton(
                            icon: Icon(isEditing ? Icons.check : Icons.edit),
                            onPressed: () {
                              setState(() {
                                if (isEditing) {
                                  if (projectNameController.text
                                      .trim()
                                      .isEmpty) {
                                    return;
                                  }
                                  projectName = projectNameController.text;
                                }
                                isEditing = !isEditing;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _animation,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            final delay = index * 0.2;
                            final startValue = delay;
                            final endValue = delay + 0.8;
                            final currentValue = _animation.value;

                            double animatedValue = 0.0;
                            if (currentValue >= startValue &&
                                currentValue <= endValue) {
                              animatedValue =
                                  (currentValue - startValue) /
                                  (endValue - startValue);
                            } else if (currentValue > endValue) {
                              animatedValue = 1.0;
                            }

                            return Transform.translate(
                              offset: Offset(0, 20 * (1.0 - animatedValue)),
                              child: Opacity(
                                opacity: animatedValue,
                                child: child,
                              ),
                            );
                          },
                          child: FlowTaskItem(
                            key: ValueKey(task.id),
                            task: task,
                            isLast: index == tasks.length - 1,
                            onToggleExpand: () => toggleExpand(task.id),
                            onAddSubtask: () => addSubtask(task.id),
                            onEditTitle:
                                (title) => editTaskTitle(task.id, title),
                            onEditSubtask:
                                (subtaskIndex, title) => editSubtaskTitle(
                                  task.id,
                                  subtaskIndex,
                                  title,
                                ),
                            onDelete: () => deleteTask(task.id),
                            onDeleteSubtask:
                                (subtaskIndex) =>
                                    deleteSubtask(task.id, subtaskIndex),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addTask,
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class ProjectTask {
  final String id;
  final String title;
  final List<String> subItems;
  final bool isExpanded;

  const ProjectTask({
    required this.id,
    required this.title,
    required this.subItems,
    required this.isExpanded,
  });

  ProjectTask copyWith({
    String? title,
    List<String>? subItems,
    bool? isExpanded,
  }) {
    return ProjectTask(
      id: id,
      title: title ?? this.title,
      subItems: subItems ?? this.subItems,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subItems': subItems,
    'isExpanded': isExpanded,
  };

  factory ProjectTask.fromJson(Map<String, dynamic> json) => ProjectTask(
    id: json['id'],
    title: json['title'],
    subItems: List<String>.from(json['subItems']),
    isExpanded: json['isExpanded'],
  );
}
