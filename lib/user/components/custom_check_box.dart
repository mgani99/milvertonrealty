import 'package:flutter/material.dart';
import 'package:milvertonrealty/utils/constants.dart';

class CustomCheckBox extends StatefulWidget {
  final void Function(String) checkBoxButtonValues;
  const CustomCheckBox({super.key,
  required this.checkBoxButtonValues});
  @override
  State<CustomCheckBox> createState() => _CustomCheckBoxState();
}

class _CustomCheckBoxState extends State<CustomCheckBox> {
  bool _selected1 = false, _selected2 = false, _selected3 = false;
  Color selectedColor = Colors.grey[600]!;
  Color unselectedColor = Colors.white60!;

  String getValue(){
    if (_selected1 ) return "Owner";
    else if (_selected2 ) return "Tenant";
    else if (_selected1 ) return "Contractor";
    return "Owner";
  }


  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text("Role:", style: TextStyle(color: Colors.grey[700]),),
        SizedBox(
          width: 5,
        ),
        SizedBox(
          width :MediaQuery.of(context).size.width-80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: TextButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selected1 ? selectedColor : unselectedColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                  ),
                  onPressed: () {
                    setState(() {
                      _selected1 = !_selected1;
                      if (_selected1) {
                        _selected2 = _selected3 = false;
                      }
                      widget.checkBoxButtonValues(getValue());
                    });
                  },
                  child: Text(
                    "Owner",
                    style: TextStyle(color: _selected1? Colors.white : Colors.grey[700]),
                  ),
                ),
              ),
              SizedBox(width: 5,),
              Expanded(
                child: TextButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _selected2 ? selectedColor : unselectedColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)),),
                    onPressed: () {
                      setState(() {
                        _selected2 = !_selected2;
                        if (_selected2) {
                          _selected1 = _selected3 = false;
                        }
                        widget.checkBoxButtonValues(getValue());
                      });
                    },
                    child: Text(
                      "Tenant",
                      style: TextStyle(color: _selected2? Colors.white : Colors.grey[700]),
                    )),
              ),
              SizedBox(width: 5,),
              Expanded(
                child: TextButton(

                    style: ElevatedButton.styleFrom(
                        backgroundColor: _selected3 ? selectedColor : unselectedColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                    ),
                    onPressed: () {
                      setState(() {
                        _selected3 = !_selected3;
                        if (_selected3) {
                          _selected1 = _selected2 = false;
                        }
                        widget.checkBoxButtonValues(getValue());
                      });
                    },
                    child: Text(
                      "Contractor",
                      style: TextStyle(color: _selected3? Colors.white : Colors.grey[700]),
                    )),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
