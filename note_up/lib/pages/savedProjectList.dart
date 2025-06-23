import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'newHome.dart';


class SavedProjectsPage extends StatefulWidget {
  const SavedProjectsPage({super.key});

  @override
  State<SavedProjectsPage> createState() => _SavedProjectsPageState();
}

class _SavedProjectsPageState extends State<SavedProjectsPage> {
  List<Project> projects = [];

  @override
  void initState() {
    super.initState();
    loadProjects();
  }

  Future<void> loadProjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedProjects = prefs.getStringList('projects') ?? [];
      setState(() {
        projects = savedProjects
            .map((p) => Project.fromJson(jsonDecode(p)))
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading projects: $e')),
      );
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedProjects = prefs.getStringList('projects') ?? [];
      savedProjects.removeWhere((p) {
        final decoded = jsonDecode(p);
        return decoded['id'] == projectId;
      });
      await prefs.setStringList('projects', savedProjects);
      await loadProjects();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting project: $e')),);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Projects'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: projects.isEmpty
          ? const Center(
        child: Text(
          'No projects saved yet',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                project.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                '${project.tasks.length} tasks',
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => deleteProject(project.id),
              ),
              onTap: () {
                // Navigate back to main page with selected project
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProjectTrackerPage(
                      key: ValueKey(project.id),
                      initialProject: project,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}