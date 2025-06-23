import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class SideMenuItem {
  String name = "default";
  IconData icon = Icons.disabled_by_default;
  int index = 0;
  Color textCol2 = Colors.white;
  Color iconCol2 = Colors.white;
  Color backCol2 = Colors.grey.shade800;

  Color textCol1 = Colors.black;
  Color iconCol1 = Colors.black;
  Color backCol1 = Colors.white12;

  double padVal = 14;
  bool isDark = false;

  SideMenuItem({
    required this.name,
    required this.icon,
    required this.index,
    required this.isDark,
  });

  Widget makeTextButton(int selectedIndex, VoidCallback onTap) => Container(
    width: double.maxFinite,
    margin: EdgeInsets.only(bottom: 5),
    decoration: BoxDecoration(
      color:
      index == selectedIndex
          ? Colors.yellow
          : isDark == true
          ? backCol1
          : backCol2,
      borderRadius: BorderRadius.circular(12),
    ),
    child: GestureDetector(
      onTap: onTap,
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spa,
        children: [
          SizedBox(width: padVal),
          Icon(icon, color: isDark == true ? iconCol1 : iconCol2),
          SizedBox(width: padVal * 2),

          Container(
            width: 130,
            child: Text(
              name,
              style: GoogleFonts.montserrat(
                color: isDark == true ? textCol1 : textCol2,
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}