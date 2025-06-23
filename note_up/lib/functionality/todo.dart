import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_up/classes/todo_class.dart';
import 'package:note_up/dbs/todo_db_helper.dart';
import 'package:provider/provider.dart';

import '../Providers/themeProvider.dart';
import '../screens/HomeScreen.dart';
import '../screens/sideBar.dart';

class Todo extends StatefulWidget {
  bool isDark;
  toDOList contToDo;
  Todo({required this.isDark, required this.contToDo, super.key});

  @override
  State<Todo> createState() => _TodoState();
}

class _TodoState extends State<Todo> with WidgetsBindingObserver {
  // Add the workList item one by one
  // Retrieve them iteratively to prevent using extra work on the text editing controllers
  // Also, fix the code
  // by tomorrow - 25th May

  TextEditingController titleText = TextEditingController();
  TextEditingController todoText = TextEditingController();

  bool toggleVal = false;
  List<String> todoItems = [];

  void retrieveItems() async {
    String items = widget.contToDo.workList;
    todoItems = List<String>.from(jsonDecode(items));
    print("decodedItem: $todoItems");
  }

  @override
  void initState() {
    titleText.text = widget.contToDo.title;
    toggleVal = widget.isDark;
    retrieveItems();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    updateTodo();
    titleText.dispose();
    super.dispose();
  }

  void addItem() {
    String itemName = "Added Item";
    todoItems.add(itemName);
    String encodedItemName = jsonEncode(todoItems);
    widget.contToDo.workList = encodedItemName;
    retrieveItems();
    setState(() {});
  }

  void updateTodo() async {

    print("ID: ${widget.contToDo.id}");

    String items = jsonEncode(todoItems);
    final todom = toDOList(title: widget.contToDo.title, workList: items, id: widget.contToDo.id);
    await TodoDbHelper.instance.updateTodo(todom);
    print("Todo Saved; ${todom.workList} on ID: ${todom.id}");

  }

  Future<bool> _onWillPop() async {
    updateTodo();
    return true; // allow pop
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: context.watch<ThemeProvider>().backg,
        appBar: AppBar(
          backgroundColor: context.watch<ThemeProvider>().backg,
          title: Text(
            "To Do List",
            style: GoogleFonts.montserrat(
              color: context.watch<ThemeProvider>().textCol,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          elevation: 0.5,
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
          actions: [
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
        ),
        drawer: Sidebar(isDark: widget.isDark),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                child: Center(
                  child: TextField(
                    controller: titleText,
                    style: TextStyle(
                      color: context.read<ThemeProvider>().inputTextCol,
                    ),
                    maxLines: 1,
                    decoration: InputDecoration(
                      hintText: "Set up a title for your List",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: context.read<ThemeProvider>().buttonCol,
                        ),
                      ),
                      filled: true,
                      fillColor: context.watch<ThemeProvider>().backg,
                      // fillColor: colorMap[selectedColor] ?? Colors.white,
                    ),
                  ),
                ),
              ),
              ListView.builder(
                itemCount: todoItems.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return SizedBox(
                    height: 70,
                    width: double.maxFinite,
                    child: TextField(
                      controller: TextEditingController(text: todoItems[index]),
                      style: TextStyle(
                        color: context.read<ThemeProvider>().inputTextCol,
                      ),
                      expands: true,
                      maxLines: null,
                      minLines: null,
                      keyboardType: TextInputType.multiline,
                      textAlignVertical: TextAlignVertical.top,
                      onChanged: (value){
                        todoItems[index] = value;
                      },
                      decoration: InputDecoration(
                        hintText: "List Description",
                        hintStyle: TextStyle(
                          color: context.read<ThemeProvider>().inputTextCol,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: context.read<ThemeProvider>().buttonCol,
                          ),
                        ),
                        filled: true,
                        fillColor: context.watch<ThemeProvider>().backg,
                      ),
                    ),
                  );
                },
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    addItem();
                  },
                  child: Icon(Icons.add),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
