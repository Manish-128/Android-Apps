import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_up/functionality/Canvas.dart';
import 'package:note_up/functionality/pomodoro.dart';
import 'package:note_up/screens/HomeScreen.dart';
import 'package:note_up/screens/reminder_screens.dart';
import 'package:note_up/screens/todo_screens.dart';
import 'package:provider/provider.dart';
import '../Providers/menuProvider.dart';
import '../sub items/sidemenuitem.dart';
import 'note_screens.dart';


class Sidebar extends StatefulWidget {
  bool isDark;
  Sidebar({super.key, required this.isDark});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  double padVal = 14;
  Color textCol = Colors.white;
  Color iconCol = Colors.white;
  Color backCol = Colors.grey.shade800;
  Color circleCol = Colors.grey.shade900;
  int selectedIndex = 69;

  SideMenuItem home = SideMenuItem(
    name: "Home",
    icon: Icons.notes,
    index: 69,
    isDark: false,
  );
  SideMenuItem notes = SideMenuItem(
    name: "Notes",
    icon: Icons.notes,
    index: 0,
    isDark: false,
  );
  SideMenuItem canvas = SideMenuItem(
    name: "Canvas",
    icon: Icons.edit,
    index: 1,
    isDark: false,
  );
  SideMenuItem toDoList = SideMenuItem(
    name: "To-Do List",
    icon: Icons.list,
    index: 2,
    isDark: false,
  );
  SideMenuItem flowChart = SideMenuItem(
    name: "Flow Charts",
    icon: Icons.notes,
    index: 3,
    isDark: false,
  );
  SideMenuItem audio = SideMenuItem(
    name: "Audio",
    icon: Icons.multitrack_audio,
    index: 4,
    isDark: false,
  );
  SideMenuItem reminder = SideMenuItem(
    name: "Reminder",
    icon: Icons.watch_later,
    index: 5,
    isDark: false,
  );
  SideMenuItem pomodoro = SideMenuItem(
    name: "Pomodoro",
    icon: Icons.access_alarms,
    index: 6,
    isDark: false,
  );
  SideMenuItem archive = SideMenuItem(
    name: "Archive",
    icon: Icons.archive,
    index: 7,
    isDark: false,
  );
  SideMenuItem pinned = SideMenuItem(
    name: "Pinned",
    icon: Icons.lock,
    index: 8,
    isDark: false,
  );


  @override
  void initState() {
    if (widget.isDark) {
      textCol = Colors.black;
      iconCol = Colors.black;
      backCol = Colors.white;
      circleCol = Colors.white54;
      home.isDark = true;
      notes.isDark = true;
      canvas.isDark = true;
      toDoList.isDark = true;
      flowChart.isDark = true;
      audio.isDark = true;
      reminder.isDark = true;
      archive.isDark = true;
      pinned.isDark = true;
      pomodoro.isDark = true;
    } else {
      textCol = Colors.white;
      iconCol = Colors.white;
      backCol = Colors.grey.shade800;
      circleCol = Colors.grey.shade900;
      home.isDark = false;
      notes.isDark = false;
      canvas.isDark = false;
      toDoList.isDark = false;
      flowChart.isDark = false;
      audio.isDark = false;
      reminder.isDark = false;
      archive.isDark = false;
      pinned.isDark = false;
      pomodoro.isDark = false;

    }
    selectedIndex = context.read<MenuProvider>().selectedIndex;
    super.initState();
  }

  void notifyIndex() {
    context.read<MenuProvider>().changeIndex(inputIndex: selectedIndex);
  }

  Widget makeCircularIconButton({required IconData inputIcon}) =>
      GestureDetector(
        child: CircleAvatar(
          backgroundColor: circleCol,
          radius: 25,
          child: Icon(inputIcon, color: iconCol),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 30),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: backCol,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Center(
                child: Text(
                  "Note Up",
                  style: GoogleFonts.montserrat(
                    color: textCol,
                    wordSpacing: 4,
                    fontSize: 24,
                    letterSpacing: 3,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Divider(color: textCol),
            SizedBox(height: 10),

            home.makeTextButton(selectedIndex, (){
              setState(() {
                selectedIndex = home.index;
              });
              notifyIndex();
              Navigator.push(context, MaterialPageRoute(builder: (context)=> HomeScreen(isDark: widget.isDark,)));
            }),

            SizedBox(height: 10),
            Divider(color: textCol),
            SizedBox(height: 10),

            notes.makeTextButton(selectedIndex, () {
              setState(() {
                selectedIndex = notes.index;
              });
              notifyIndex();
              Navigator.push(context, MaterialPageRoute(builder: (context)=> NoteScreens(isDark: widget.isDark,)));
            }),
            canvas.makeTextButton(selectedIndex, () {
              setState(() {
                selectedIndex = canvas.index;
              });
              notifyIndex();
              Navigator.push(context, MaterialPageRoute(builder: (context)=> CanvasPage(isDark: widget.isDark,)));
            }),
            toDoList.makeTextButton(selectedIndex, () {
              setState(() {
                selectedIndex = toDoList.index;
              });
              notifyIndex();
              Navigator.push(context, MaterialPageRoute(builder: (context)=> TodoScreens(isDark: widget.isDark,)));
            }),
            flowChart.makeTextButton(selectedIndex, () {
              setState(() {
                selectedIndex = flowChart.index;
              });
              notifyIndex();
            }),
            audio.makeTextButton(selectedIndex, () {
              setState(() {
                selectedIndex = audio.index;
              });
              notifyIndex();
            }),
            reminder.makeTextButton(selectedIndex, () {
              setState(() {
                selectedIndex = reminder.index;
              });
              notifyIndex();
              Navigator.push(context, MaterialPageRoute(builder: (context)=> ReminderScreens(isDark: widget.isDark,)));
            }),
            pomodoro.makeTextButton(selectedIndex, () {
              setState(() {
                selectedIndex = pomodoro.index;
              });
              notifyIndex();
              Navigator.push(context, MaterialPageRoute(builder: (context)=> Pomodoro(isDark: widget.isDark)));
            }),

            SizedBox(height: 10),
            Divider(color: textCol),
            SizedBox(height: 10),
            archive.makeTextButton(selectedIndex, () {
              setState(() {
                selectedIndex = archive.index;
              });
              notifyIndex();
            }),
            pinned.makeTextButton(selectedIndex, () {
              setState(() {
                selectedIndex = pinned.index;
              });
              notifyIndex();
            }),

            SizedBox(height: 10),
            Divider(color: textCol),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                makeCircularIconButton(inputIcon: Icons.account_box),
                makeCircularIconButton(inputIcon: Icons.sync),
                makeCircularIconButton(inputIcon: Icons.settings),
              ],
            ),
            SizedBox(height: 10),

            Divider(color: textCol),
          ],
        ),
      ),
    );
  }
}
