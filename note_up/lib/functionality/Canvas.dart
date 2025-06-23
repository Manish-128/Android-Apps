import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../Providers/themeProvider.dart';
import '../screens/sideBar.dart';

class CanvasPage extends StatefulWidget {

  bool isDark;
  CanvasPage({ required this.isDark,super.key});


  @override
  State<CanvasPage> createState() => _CanvasPageState();
}

class _CanvasPageState extends State<CanvasPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.watch<ThemeProvider>().backg,
      appBar: AppBar(
        backgroundColor: context.watch<ThemeProvider>().backg,
        title: Text(
          "Canvas",
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
      ),
      drawer: Sidebar(isDark: widget.isDark),

      body: Padding(padding: EdgeInsets.fromLTRB(10, 20, 10, 0)),

    );
  }
}
