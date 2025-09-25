import 'package:flutter/material.dart';

/// An editable dropdown: lets the user type freely or choose
/// one of the provided [items].
class ComboBox extends StatefulWidget {
  final List<String> items;
  final String? initialValue;
  final String hintText;
  final String inputDeco;

  final ValueChanged<String> onChanged;

  const ComboBox({
    Key? key,
    required this.items,
    required this.onChanged,
    this.initialValue,
    this.hintText = '',
    this.inputDeco = '',

  }) : super(key: key);

  @override
  _EditableDropdownState createState() => _EditableDropdownState();
}

class _EditableDropdownState extends State<ComboBox> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late List<String> _filteredItems;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _focusNode = FocusNode();
    _filteredItems = widget.items;

    // Refilter and show dropdown when user types
    _controller.addListener(_onTextChanged);

    // Show dropdown on focus, hide on blur
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    });
  }

  @override
  void didUpdateWidget(covariant ComboBox old) {
    super.didUpdateWidget(old);
    // Reapply external changes to text
    if (widget.initialValue != old.initialValue) {
      _controller.text = widget.initialValue ?? '';
      _filterItems(_controller.text);
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

 /* void _onTextChanged() {
    _filterItems(_controller.text);
    _refreshOverlay();
    widget.onChanged(_controller.text);
  }*/
  void _onTextChanged() {
    _filterItems(_controller.text);

    // schedule overlay refresh + parent callback after this build finishes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // only refresh if overlay is showing
      _overlayEntry?.markNeedsBuild();
      widget.onChanged(_controller.text);
    });
  }

  void _filterItems(String query) {
    final lower = query.toLowerCase();
    _filteredItems = widget.items
        .where((item) => item.toLowerCase().contains(lower))
        .toList();
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    final renderBox = context.findRenderObject() as RenderBox;
    final fieldSize = renderBox.size;
    final fieldOffset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: fieldOffset.dx,
        top: fieldOffset.dy + fieldSize.height + 4,
        width: fieldSize.width,
        child: Material(
          elevation: 4,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final option = _filteredItems[index];
                return ListTile(
                  title: Text(option),
                  onTap: () {
                    _controller.text = option;
                    _controller.selection = TextSelection.collapsed(
                      offset: option.length,
                    );
                    widget.onChanged(option);
                    _removeOverlay();
                    _focusNode.unfocus();
                  },
                );
              },
            ),
          ),
        ),
      ),
    );

    Overlay.of(context)?.insert(_overlayEntry!);
  }

  void _refreshOverlay() {
    _overlayEntry?.markNeedsBuild();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: InputDecoration(
        labelText: widget.inputDeco,
        hintText: widget.hintText,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixIcon: IconButton(
          icon: const Icon(Icons.arrow_drop_down),
          onPressed: () {
            if (_overlayEntry == null) {
              _focusNode.requestFocus();
              _showOverlay();
            } else {
              _removeOverlay();
              _focusNode.unfocus();
            }
          },
        ),
      ),
    );
  }
}
