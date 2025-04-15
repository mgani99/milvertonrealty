import 'package:flutter/material.dart';



class IncrementDecrementTextBox extends StatefulWidget {
  final int initialValue;
  final ValueChanged<int> onChanged;

  IncrementDecrementTextBox({this.initialValue = 0, required this.onChanged});


  @override
  _IncrementDecrementTextBoxState createState() =>
      _IncrementDecrementTextBoxState();
}

class _IncrementDecrementTextBoxState extends State<IncrementDecrementTextBox> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue.toString());
  }

  void _increment() {
    int currentValue = int.tryParse(_controller.text) ?? 0;
    setState(() {
      currentValue++;
      _controller.text = currentValue.toString();
    });
    widget.onChanged(currentValue);
  }

  void _decrement() {
    int currentValue = int.tryParse(_controller.text) ?? 0;
    setState(() {
      currentValue--;
      _controller.text = currentValue.toString();
    });
    widget.onChanged(currentValue);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: TextField(
        controller: _controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        onChanged: (value) => widget.onChanged(int.parse(value)),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(3),
          suffixIcon: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _increment,
                child: Icon(
                  Icons.arrow_drop_up,
                  size: 20,
                  color: Colors.green,
                ),
              ),
              GestureDetector(
                onTap: _decrement,
                child: Icon(
                  Icons.arrow_drop_down,
                  size: 20,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}


class UserProfileTextBox extends StatelessWidget {
  final String text;
  final String sectionName;
  final void Function()? onTap;


  const UserProfileTextBox({
    super.key,
    required this.text,
    required this.sectionName,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.only(left:15, bottom: 15),
      margin: const EdgeInsets.only(left:20,right:20,top:20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sectionName,
                style: TextStyle(color: Colors.grey[500]),
              ),
              IconButton(
                  onPressed: onTap,
                  icon: Icon(Icons.settings,
                    color: Colors.grey[400],
                  )
              )
            ],
          ),
          Text(
            this.text,
            style: TextStyle(color: Colors.black),),
        ],
      ),
    );
  }


}
