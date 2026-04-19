import 'package:flutter/material.dart';
void main() {
  DatePickerThemeData theme = DatePickerThemeData(
    dayShape: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return const CircleBorder(side: BorderSide(color: Colors.red, width: 2));
      }
      return const CircleBorder();
    }),
  );
}
