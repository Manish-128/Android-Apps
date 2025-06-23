import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_up/Providers/themeProvider.dart';
import 'package:note_up/pages/LogViewer.dart';
import 'package:note_up/screens/code_screen.dart';
import 'package:note_up/screens/location_screen.dart';
import 'package:note_up/screens/sideBar.dart';
import 'package:note_up/screens/watchlistScreen.dart';
import 'package:provider/provider.dart';
import 'package:note_up/functionality/SpeechToText.dart';
import '../main.dart' as mn;
import 'package:note_up/functionality/DSAHelper.dart';



final GlobalKey<_HomeScreenState> myKey = GlobalKey<_HomeScreenState>();

class HomeScreen extends StatefulWidget {
  bool isDark;
  HomeScreen({required this.isDark, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Widget buildCard(String imgAddress, String imgName, Color col) => Container(
    decoration: BoxDecoration(color: Colors.transparent),
    height: 150,
    width: 150,
    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    child: Card(
      elevation: 10, // 👈 controls the depth of the shadow
      shadowColor: col,
      clipBehavior: Clip.antiAlias,

      child: Stack(
        children: [
          // Positioned.fill(child: Opacity(opacity: 0.65, child: Image.network(imgAddress, fit: BoxFit.cover,),), ),
          Container(color: col),
          Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset(imgAddress, height: 65, width: 65),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                imgName,
                style: GoogleFonts.alatsi(fontSize: 26, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  bool toggleVal = false;
  bool sideTogg = false;

  void showTestNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'test_channel_id',
          'Test Notifications',
          channelDescription: 'This channel is for testing notifications',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await mn.flutterLocalNotificationsPlugin.show(
      0,
      'Hello!',
      'This is a test notification.',
      platformChannelSpecifics,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.watch<ThemeProvider>().backg,
      appBar: AppBar(
        backgroundColor: context.watch<ThemeProvider>().backg,
        title: Text(
          "Note Up",
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
      drawer: Sidebar(isDark: toggleVal),
      body: Padding(
        padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
        child: Column(
          children: [
            SizedBox(
              height: 6 * 72,
              child: GridView.builder(
                padding: EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  // crossAxisSpacing: 10,
                  // mainAxisSpacing: 10,
                  childAspectRatio: 5 / 4,
                ),
                itemCount: 6, // total cards
                itemBuilder: (context, index) {
                  final ImgName = [
                    'Notes',
                    'Canvas',
                    'To-Do List',
                    'Flow Charts',
                    'Tree Diagram',
                    'Audio',
                  ];
                  final ImgAddress = [
                    "assets/icons/panda.png",
                    "assets/icons/kitty.png",
                    "assets/icons/frog.png",
                    "assets/icons/puppy.png",
                    "assets/icons/cool.png",
                    "assets/icons/dinosaur.png",
                  ];
                  final Col = [
                    Color(0xFFFFC1CC),
                    Color(0xFFFFD580),
                    Color(0xFFB5EAD7),
                    Color(0xFFFFF59D),
                    Color(0xFFFDCB82),
                    Color(0xFFA0E7E5),
                  ];
                  return buildCard(
                    ImgAddress[index],
                    ImgName[index],
                    Col[index],
                  );
                },
              ),
            ),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  // showTestNotification();
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WatchListScreen(isDark: widget.isDark,)),
                    );
                  }
                },
                child: Text("Watch List"),
              ),
            ),
            const SizedBox(height: 10,),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // showTestNotification();
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LocationMonitorPage()),
                    );
                  }
                },
                child: Text("Location Screen"),
              ),
            ),

            const SizedBox(height: 10,),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // showTestNotification();
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => VoiceLogViewerPage()),
                    );
                  }
                },
                child: Text("Log Viewer"),
              ),
            ),
            const SizedBox(height: 10,),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SpeechToTextPage()),
                    );
                  }
                },
                child: Text("STT"),
              ),
            ),

            const SizedBox(height: 10,),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CodeScreen(isDark: widget.isDark)),
                    );
                  }
                },
                child: Text("Code Screen"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThemeUtils {
  static void changeTheme(BuildContext context, bool switchVal) {
    if (switchVal) {
      context.read<ThemeProvider>().changeTextCol(inputCol: Colors.yellow);
      context.read<ThemeProvider>().changeBg(inputCol: Colors.grey[800]);
      context.read<ThemeProvider>().changeButtCol(inputCol: Colors.white);
      context.read<ThemeProvider>().changeInputTextCol(inputCol: Colors.white);
    } else {
      context.read<ThemeProvider>().changeTextCol(inputCol: Colors.black);
      context.read<ThemeProvider>().changeBg(inputCol: Colors.grey.shade200);
      context.read<ThemeProvider>().changeButtCol(inputCol: Colors.black);
      context.read<ThemeProvider>().changeInputTextCol(inputCol: Colors.black);
    }
  }
}
