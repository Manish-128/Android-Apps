import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_up/classes/todo_class.dart';
import 'package:note_up/dbs/todo_db_helper.dart';
import 'package:note_up/functionality/todo.dart';
import 'package:note_up/screens/sideBar.dart';
import 'package:provider/provider.dart';

import '../Providers/themeProvider.dart';
import 'HomeScreen.dart';

class TodoScreens extends StatefulWidget {
  bool isDark;
  TodoScreens({required this.isDark, super.key});

  @override
  State<TodoScreens> createState() => _TodoScreensState();
}

class _TodoScreensState extends State<TodoScreens> {
  bool toggleVal = false;
  List<toDOList> todos = [];

  @override
  void initState() {
    toggleVal = widget.isDark;
    loadTodo();
    super.initState();
  }

  Future<bool> loadTodo() async {
    final todoN = await TodoDbHelper.instance.readAllTodos();
    setState(() {
      todos = todoN;
    });
    return true;
  }

  void addTodo() async {
    List<String> items = ["First Work"];
    String encodedItems = jsonEncode(items);
    final todo = toDOList(title: 'My Todo', workList: encodedItems);

    final Dbid = await TodoDbHelper.instance.createTodo(todo);
    print("DB ID generated is : $Dbid");
    final savedtodo = toDOList(
      id: Dbid,
      title: todo.title,
      workList: todo.workList,
    );

    print("DB ID generated is : ${savedtodo.id}");


    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => Todo(isDark: widget.isDark, contToDo: savedtodo),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.watch<ThemeProvider>().backg,
      appBar: AppBar(
        backgroundColor: context.watch<ThemeProvider>().backg,
        title: Text(
          "To-DO List",
          style: GoogleFonts.montserrat(
            color: context.watch<ThemeProvider>().textCol,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0.5,
        actions: [
          IconButton(
            onPressed: () {
              loadTodo();
              setState(() {});
            },
            icon: Icon(Icons.refresh_sharp),
            color: context.watch<ThemeProvider>().buttonCol,
          ),
          IconButton(
            onPressed: () {
              setState(() {
                toggleVal = !toggleVal;
              });
              ThemeUtils.changeTheme(context, toggleVal);
            },
            icon: Padding(
              padding: EdgeInsets.all(5.0),
              child:
                  toggleVal == true
                      ? Icon(Icons.toggle_on_outlined)
                      : Icon(Icons.toggle_off_outlined),
            ),
            iconSize: 36,
            color: context.watch<ThemeProvider>().buttonCol,
          ),
        ],
        leading: Builder(
          builder:
              (context) => IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: Icon(Icons.list),
                color: context.read<ThemeProvider>().buttonCol,
              ),
        ),
        bottomOpacity: 1.0,
      ),
      drawer: Sidebar(isDark: widget.isDark),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addTodo();
        },
        backgroundColor: Colors.tealAccent.shade100,
        child: Icon(Icons.add, size: 30),
      ),
      body: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              toDOList contTodo = todos[index];
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            Todo(isDark: widget.isDark, contToDo: contTodo),
                  ),
                );
              }
            },
            child: ListTile(
              leading: Text(index.toString()),
              title: Text(todos[index].title),
            ),
          );
        },
      ),
    );
  }
}
