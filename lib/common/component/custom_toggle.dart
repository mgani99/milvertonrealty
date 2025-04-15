
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:milvertonrealty/utils/constants.dart';

class CustomToggleButtons extends StatefulWidget {
  final List<String> options;
  final Function(String) onOptionSelected;

  const CustomToggleButtons({
    Key? key,
    required this.options,
    required this.onOptionSelected,
  }) : super(key: key);

  @override
  _CustomToggleButtonsState createState() => _CustomToggleButtonsState();
}

class _CustomToggleButtonsState extends State<CustomToggleButtons> {
  late List<bool> isSelected;

  @override
  void initState() {
    super.initState();
    isSelected = List<bool>.filled(widget.options.length, false);
    isSelected[0] = true; // Default selection
  }

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      isSelected: isSelected,
      onPressed: (int index) {
        setState(() {
          for (int i = 0; i < isSelected.length; i++) {
            isSelected[i] = i == index;
          }
        });
        widget.onOptionSelected(widget.options[index]);
      },
      borderRadius: BorderRadius.circular(10.0),
      borderColor: Colors.grey,
      selectedBorderColor: ColorConstants.primaryColor,
      selectedColor: Colors.white,
      fillColor: Colors.grey,
      color: ColorConstants.primaryColor,
      constraints: BoxConstraints(minWidth: 105, minHeight: 50),
      children: widget.options.map((option) => Text(option)).toList(),
    );
  }
}
class ToggleButtonWidget extends StatefulWidget {
  bool isVacant = false;
  ToggleButtonWidget({required this.isVacant});
  @override
  _ToggleButtonWidgetState createState() => _ToggleButtonWidgetState();
}

class _ToggleButtonWidgetState extends State<ToggleButtonWidget> {
  //bool isVacant = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.isVacant = !widget.isVacant;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: widget.isVacant
                ? [Colors.orange.shade200, Colors.orange.shade400]
                : [Colors.green.shade200, Colors.green.shade400],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          widget.isVacant ? "Vacant" : "Occupied",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch, // For touch devices like smartphones
    PointerDeviceKind.mouse, // For mouse devices on desktop or web
  };
}
