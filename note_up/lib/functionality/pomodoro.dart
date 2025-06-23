import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../Providers/themeProvider.dart';
import '../classes/notification_class.dart';
import '../main.dart';
import '../screens/HomeScreen.dart';
import '../screens/sideBar.dart';

class Pomodoro extends StatefulWidget {
  bool isDark;
  Pomodoro({required this.isDark, super.key});

  @override
  State<Pomodoro> createState() => _PomodoroState();
}

class _PomodoroState extends State<Pomodoro> with WidgetsBindingObserver {
  bool showTimer = false;
  bool toggleVal = false;
  TimeOfDay? selectedTime;
  FixedExtentScrollController controller1 = FixedExtentScrollController();
  FixedExtentScrollController controller2 = FixedExtentScrollController();
  bool startedPomodoro = false;
  int selectedWorkMins = 1;
  int selectedBreakMins = 1;
  TimeOfDay _workNotTimeAfterSending = TimeOfDay.now();
  TimeOfDay _breakNotTimeAfterSending = TimeOfDay.now();

  final List<int> numbers = List.generate(60, (index) => index + 1);

  @override
  void initState() {
    toggleVal = widget.isDark;
    selectedTime = TimeOfDay.now();
    retrieveRemInfo();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  TimeOfDay addMinutes(TimeOfDay time, int minutesToAdd) {
    // Convert to DateTime (with today's date just for calculation)
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Add minutes
    final newDateTime = dateTime.add(Duration(minutes: minutesToAdd));

    // Convert back to TimeOfDay
    return TimeOfDay(hour: newDateTime.hour, minute: newDateTime.minute);
  }

  void retrieveRemInfo() {}

  void startNotifications() async {
    TimeOfDay workNotiTime = addMinutes(
      selectedTime ?? TimeOfDay.now(),
      (selectedWorkMins + selectedBreakMins),
    );
    _workNotTimeAfterSending = workNotiTime;
    TimeOfDay breakNotiTime = addMinutes(
      selectedTime ?? TimeOfDay.now(),
      selectedWorkMins,
    );
    _breakNotTimeAfterSending = breakNotiTime;

    customNotification breakNotification = customNotification(
      title: "Pomodoro Timing Alert",
      subTitle: "Take a Break dude",
      plugin: flutterLocalNotificationsPlugin,
    );
    customNotification workNotification = customNotification(
      title: "Pomodoro Timing Alert",
      subTitle: "Let's Start Working",
      plugin: flutterLocalNotificationsPlugin,
    );
    await workNotification.scheduledSimpleNotification(
      time: workNotiTime,
      date: DateTime.now(),
      id: 69,
    );
    await breakNotification.scheduledSimpleNotification(
      time: breakNotiTime,
      date: DateTime.now(),
      id: 70,
    );
  }

  bool hasPassed(TimeOfDay time1, TimeOfDay time2) {
    final int t1Minutes = time1.hour * 60 + time1.minute;
    final int t2Minutes = time2.hour * 60 + time2.minute;
    return t1Minutes > t2Minutes; // true if time1 is later than time2
  }

  void cancelNotification() async{

    customNotification cancellingNotif = customNotification(plugin: flutterLocalNotificationsPlugin, title: "", subTitle: "");
    if(!hasPassed(TimeOfDay.now(),_workNotTimeAfterSending)){
      cancellingNotif.cancelNotification(69);
    }
    if(!hasPassed(TimeOfDay.now(),_breakNotTimeAfterSending)){
      cancellingNotif.cancelNotification(70);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void updatePomo() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.watch<ThemeProvider>().backg,
      appBar: AppBar(
        backgroundColor: context.watch<ThemeProvider>().backg,
        title: Text(
          "Pomodoro",
          style: GoogleFonts.montserrat(
            color: context.watch<ThemeProvider>().textCol,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Starting Time Section
            Text(
              "Starting Time",
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: context.watch<ThemeProvider>().textCol,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              // onTap: () {
              //   _showTimePicker();
              //   print("Picked Time: $selectedTime");
              // },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: context.watch<ThemeProvider>().backg,
                ),
                child: Text(
                  selectedTime != null
                      ? selectedTime!.format(context)
                      : "Select Time",
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    color: context.watch<ThemeProvider>().textCol,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Work & Break Pickers
            if (!startedPomodoro)...[

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _styledPickerBox("Work", controller1, (index) {
                    setState(() => selectedWorkMins = numbers[index]);
                  }, selectedValue: selectedWorkMins),

                  _styledPickerBox("Break", controller2, (index) {
                    setState(() => selectedBreakMins = numbers[index]);
                  }, selectedValue: selectedBreakMins),
                ],
              ),
            ],


            const SizedBox(height: 40),

            // Start/Stop Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  setState((){
                    startedPomodoro = !startedPomodoro;
                    selectedTime = TimeOfDay.now();
                  });
                  if(startedPomodoro){
                    startNotifications();
                  }else{
                    cancelNotification();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.read<ThemeProvider>().buttonCol,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  startedPomodoro ? "Stop" : "Start",
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPicker(
    FixedExtentScrollController controller,
    ValueChanged<int> onSelected, {
    required int selectedValue, // <-- new param to track selected item
  }) {
    return Container(
      width: 80,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey.shade200.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: 40,
            physics: FixedExtentScrollPhysics(),
            onSelectedItemChanged: onSelected,
            perspective: 0.005,
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                if (index < 0 || index >= numbers.length) return null;
                bool isSelected = numbers[index] == selectedValue;

                return Center(
                  child: Text(
                    "${numbers[index]}",
                    style: TextStyle(
                      fontSize: isSelected ? 24 : 18,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.black : Colors.blue,
                    ),
                  ),
                );
              },
            ),
          ),
          // Optional: Add a highlight line to visually separate selected area
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                border: Border.symmetric(
                  horizontal: BorderSide(color: Colors.blueAccent, width: 1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _styledPickerBox(
    String label,
    FixedExtentScrollController controller,
    ValueChanged<int> onSelected, {
    required int selectedValue,
  }) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey.shade200.withOpacity(0.6),
          ),
          child: _buildPicker(
            controller,
            onSelected,
            selectedValue: selectedValue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "$label Minutes",
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
