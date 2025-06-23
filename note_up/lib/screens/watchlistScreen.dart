import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:note_up/classes/watchlist_class.dart';
import 'package:note_up/functionality/watchHistory.dart';
import 'package:note_up/screens/sideBar.dart';
import 'package:provider/provider.dart';

import '../Providers/themeProvider.dart';
import '../dbs/watchlist_db_helper.dart';
import 'HomeScreen.dart';

class WatchListScreen extends StatefulWidget {
  bool isDark;
  WatchListScreen({required this.isDark, Key? key}) : super(key: key);

  @override
  State<WatchListScreen> createState() => _WatchListScreenState();
}

class _WatchListScreenState extends State<WatchListScreen> {
  late Future<List<WatchListClass>> _watchlistFuture;
  bool toggleVal = false;


  void addWatch() async {
    WatchListClass tempWatch = WatchListClass(title: '', year: 0000, image: '');
    int DbId = await WatchListDbHelper.instance.createWatchlist(tempWatch);
    WatchListClass contWatch = WatchListClass(id: DbId ,title: tempWatch.title, year: tempWatch.year, image: tempWatch.image);
    if(mounted){
      Navigator.push(context, MaterialPageRoute(builder: (context)=> WatchHistory(isDark: widget.isDark, contWatch: contWatch)));
    }
  }

  @override
  void initState() {
    super.initState();
    loadWatch();
  }

  Future<void> loadWatch() async{
    _watchlistFuture = WatchListDbHelper.instance.readAllWatchlist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.watch<ThemeProvider>().backg,
      appBar: AppBar(
        backgroundColor: context.watch<ThemeProvider>().backg,
        title: Text(
          "Watch List",
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
              loadWatch();
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
          addWatch();
        },
        backgroundColor: Colors.tealAccent.shade100,
        child: Icon(Icons.add, size: 30),
      ),
      body: FutureBuilder<List<WatchListClass>>(
        future: _watchlistFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No watchlist entries found.'));
          }

          final watchlist = snapshot.data!;

          return ListView.builder(
            itemCount: watchlist.length,
            itemBuilder: (context, index) {
              final item = watchlist[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(item.image),
                      width: 60,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported),
                    ),
                  ),
                  title: Text(item.title),
                  subtitle: Text('Year: ${item.year}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
