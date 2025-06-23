import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_up/classes/reminder_class.dart';
import 'package:note_up/dbs/reminder_db_helper.dart';
import 'package:note_up/functionality/reminder.dart';
import 'package:note_up/screens/sideBar.dart';
import 'package:provider/provider.dart';

import '../Providers/themeProvider.dart';
import 'HomeScreen.dart';

class ReminderScreens extends StatefulWidget {
  bool isDark;
  ReminderScreens({required this.isDark, super.key});

  @override
  State<ReminderScreens> createState() => _ReminderScreensState();
}

class _ReminderScreensState extends State<ReminderScreens> {
  bool toggleVal = false;
  List<Reminder> reminders = [];

  @override
  void initState() {
    toggleVal = widget.isDark;
    loadRem();
    super.initState();
  }

  Future<bool> loadRem() async {
    reminders = await ReminderDbHelper.instance.readAllRemainder();
    setState(() {

    });
    return true;
  }

  void addRem() async {
    Reminder tempRem = Reminder(title: "Default", time: TimeOfDay.now().toString(), date: DateTime.now().toString());
    int DbId = await ReminderDbHelper.instance.createRegister(tempRem);
    Reminder contRem = Reminder(id: DbId ,title: tempRem.title, time: tempRem.time, date: tempRem.date);
    if(mounted){
      Navigator.push(context, MaterialPageRoute(builder: (context)=> ReminderF(isDark: widget.isDark, contRem: contRem)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.watch<ThemeProvider>().backg,
      appBar: AppBar(
        backgroundColor: context.watch<ThemeProvider>().backg,
        title: Text(
          "Reminders",
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
              loadRem();
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
          addRem();
        },
        backgroundColor: Colors.tealAccent.shade100,
        child: Icon(Icons.add, size: 30),
      ),
      body: ListView.builder(
        itemCount: reminders.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Reminder contRem = reminders[index];
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                        ReminderF(isDark: widget.isDark, contRem: contRem),
                  ),
                );
              }
            },
            child: ListTile(
              leading: Text(index.toString()),
              title: Text(reminders[index].title),
              trailing: SizedBox(
                width: 100,
                child: Center(
                  child: Column(
                    children: [
                      Text(reminders[index].time.replaceAll(RegExp(r'[^0-9:]'), '')),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(DateTime.parse(reminders[index].date).day.toString()),
                          Text("-"),
                          Text(DateTime.parse(reminders[index].date).month.toString()),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
