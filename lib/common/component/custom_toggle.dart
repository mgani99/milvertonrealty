
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