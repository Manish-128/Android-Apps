import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:note_up/dbs/reminder_db_helper.dart';
import 'package:note_up/main.dart';
import 'package:provider/provider.dart';
import '../Providers/themeProvider.dart';
import '../classes/notification_class.dart';
import '../classes/reminder_class.dart';
import '../screens/HomeScreen.dart';
import '../screens/sideBar.dart';

class ReminderF extends StatefulWidget {
  bool isDark;
  Reminder contRem;
  ReminderF({required this.isDark, required this.contRem, super.key});

  @override
  State<ReminderF> createState() => _ReminderFState();
}

class _ReminderFState extends State<ReminderF> with WidgetsBindingObserver {
  TextEditingController titleText = TextEditingController();
  TextEditingController subTitleText = TextEditingController();
  bool showTimer = false;
  bool toggleVal = false;
  TimeOfDay? selectedTime;
  DateTime? selectedDate;


  @override
  void initState() {
    titleText.text = widget.contRem.title;
    subTitleText.text = "Sub Title";
    toggleVal = widget.isDark;
    retrieveRemInfo();
    super.initState();
    WidgetsBinding.instance.addObserver(this);

  }
  void retrieveRemInfo() {
    String timeString = widget.contRem.time.replaceAll(RegExp(r'[^0-9:]'), '');
    selectedTime = TimeOfDay(
      hour: int.parse(timeString.split(":")[0]),
      minute: int.parse(timeString.split(":")[1]),
    );
    selectedDate = DateTime.parse(widget.contRem.date);
  }

  Future<void> _showTimePicker() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    titleText.dispose();
    super.dispose();
  }

  void updateRem({
    required DateTime selectedDate,
    required TimeOfDay selectedTime,
  }) async {

    print("Selected DateTime is $selectedDate and selected TimeOfDay is $selectedTime");


    if (selectedTime.isAfter(TimeOfDay.now())) {

      customNotification notification = customNotification(title: titleText.text.trim(), subTitle: subTitleText.text.trim(), plugin: flutterLocalNotificationsPlugin);
      await notification.scheduledSimpleNotification(time: selectedTime, date: selectedDate, id: 1);

      Reminder tempRem = Reminder(
        id: widget.contRem.id,
        title: titleText.text.trim(),
        time: selectedTime.toString(),
        date: selectedDate.toString(),
      );
      await ReminderDbHelper.instance.updateRemainder(tempRem);
      print(
        "Saved Reminder with id: ${tempRem.id}, Title: ${tempRem.title}, Time: ${tempRem.time}, Date: ${tempRem.date}",
      );

      Navigator.pop(context);
    } else {
      print("Select Valid Day and Time");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.watch<ThemeProvider>().backg,
      appBar: AppBar(
        backgroundColor: context.watch<ThemeProvider>().backg,
        title: Text(
          "Reminder",
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
              height: 70,
              width: double.maxFinite,
              child: TextField(
                controller: titleText,
                style: TextStyle(
                  color: context.read<ThemeProvider>().inputTextCol,
                ),
                maxLines: 1,
                decoration: InputDecoration(
                  hintText: "Title of your Reminder....",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: context.read<ThemeProvider>().buttonCol,
                    ),
                  ),
                  filled: true,
                  fillColor: context.watch<ThemeProvider>().backg,
                ),
              ),
            ),
            SizedBox(height: 30),
            SizedBox(
              height: 70,
              width: double.maxFinite,
              child: TextField(
                controller: subTitleText,
                style: TextStyle(
                  color: context.read<ThemeProvider>().inputTextCol,
                ),
                maxLines: 1,
                decoration: InputDecoration(
                  hintText: "Title of your Reminder....",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: context.read<ThemeProvider>().buttonCol,
                    ),
                  ),
                  filled: true,
                  fillColor: context.watch<ThemeProvider>().backg,
                ),
              ),
            ),
            SizedBox(height: 30,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  selectedTime != null
                      ? selectedTime!.format(context)
                      : "No time selected",
                  style: TextStyle(fontSize: 24),
                ),

                TextButton(
                  onPressed: () {
                    _showTimePicker();
                  },
                  child: Text("Reset"),
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  selectedDate != null
                      ? DateFormat('dd MMM yyyy').format(selectedDate!)
                      : "No Date selected",
                  style: TextStyle(fontSize: 24),
                ),

                TextButton(
                  onPressed: () {
                    _showDatePicker();
                  },
                  child: Text("Reset"),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child:
                  (selectedTime) != null
                      ? (selectedDate) != null
                          ? IconButton(
                            onPressed: () {
                              updateRem(
                                selectedDate: selectedDate ?? DateTime.now(),
                                selectedTime: selectedTime ?? TimeOfDay.now(),
                              );
                            },
                            icon: Icon(Icons.save),
                          )
                          : Text("Select Date and Time")
                      : Text("Select Date and Time"),
            ),
          ],
        ),
      ),
    );
  }
}
