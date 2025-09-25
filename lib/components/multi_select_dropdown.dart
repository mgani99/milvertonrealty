import 'package:flutter/material.dart';

/// A dropdown‐style button that allows picking multiple values from [items].
///
/// T can be any type. You provide:
///  • items: full list of options
///  • initialSelectedValues: the ones you want pre‐checked
///  • itemLabel: how to turn a T into a String for display
///  • onSelectionChanged: called with the new List<T> when the user confirms
///  • title: optional dialog title
class MultiSelectDropdown<T> extends StatefulWidget {
  final List<T> items;
  final List<T> initialSelectedValues;
  final String title;
  final String Function(T) itemLabel;
  final ValueChanged<List<T>> onSelectionChanged;

  const MultiSelectDropdown({
    Key? key,
    required this.items,
    required this.initialSelectedValues,
    required this.itemLabel,
    required this.onSelectionChanged,
    this.title = 'Select values',
  }) : super(key: key);

  @override
  _MultiSelectDropdownState<T> createState() =>
      _MultiSelectDropdownState<T>();
}

class _MultiSelectDropdownState<T> extends State<MultiSelectDropdown<T>> {
  late List<T> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List<T>.from(widget.initialSelectedValues);
  }

  @override
  void didUpdateWidget(covariant MultiSelectDropdown<T> old) {
    super.didUpdateWidget(old);
    if (old.initialSelectedValues != widget.initialSelectedValues) {
      _selected = List<T>.from(widget.initialSelectedValues);
    }
  }

  Future<void> _showMultiSelectDialog() async {
    final result = await showDialog<List<T>>(
      context: context,
      builder: (ctx) {
        return _MultiSelectDialog<T>(
          title: widget.title,
          items: widget.items,
          initialSelected: _selected,
          itemLabel: widget.itemLabel,
        );
      },
    );

    if (result != null) {
      setState(() => _selected = result);
      widget.onSelectionChanged(_selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAllSelected = _selected.any((item) => widget.itemLabel(item) == 'All');
    // Display comma-separated labels, or a hint if none selected
    final label = isAllSelected
        ? 'All'
        : _selected.isEmpty
        ? 'None'
        : _selected.map(widget.itemLabel).join(', ');

    return GestureDetector(
      onTap: _showMultiSelectDialog,
      child: InputDecorator(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.arrow_drop_down),
          contentPadding:
          EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        isEmpty: _selected.isEmpty,
        child: Text(label),
      ),
    );
  }
}

/// The dialog that actually shows a scrollable list of checkboxes.
class _MultiSelectDialog<T> extends StatefulWidget {
  final List<T> items;
  final List<T> initialSelected;
  final String title;
  final String Function(T) itemLabel;

  const _MultiSelectDialog({
    Key? key,
    required this.items,
    required this.initialSelected,
    required this.itemLabel,
    required this.title,
  }) : super(key: key);

  @override
  __MultiSelectDialogState<T> createState() =>
      __MultiSelectDialogState<T>();
}

class __MultiSelectDialogState<T> extends State<_MultiSelectDialog<T>> {
  late List<T> _tempSelected;

  @override
  void initState() {
    super.initState();
    _tempSelected = List<T>.from(widget.initialSelected);
  }
  void _onItemCheckedChange(T item, bool checked) {
    setState(() {
      if (widget.itemLabel(item) == 'All') {
        if (checked) {
          _tempSelected = List<T>.from(widget.items);
        } else {
          _tempSelected.clear();
        }
      } else {
        if (checked) {
          _tempSelected.add(item);
          // If all items except "All" are selected, auto-select "All"
          final allExceptAll = widget.items.where((i) => widget.itemLabel(i) != 'All');
          final selectedExceptAll = _tempSelected.where((i) => widget.itemLabel(i) != 'All');
          if (selectedExceptAll.length == allExceptAll.length) {
            final allItem = widget.items.firstWhere((i) => widget.itemLabel(i) == 'All');
            if (!_tempSelected.contains(allItem)) _tempSelected.add(allItem);
          }
        } else {
          _tempSelected.remove(item);
          // If "All" is selected, unselect it when any item is deselected
          final allItem = widget.items.firstWhere((i) => widget.itemLabel(i) == 'All');
          _tempSelected.remove(allItem);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      contentPadding: const EdgeInsets.only(top: 12),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.items.map((item) {
            final label = widget.itemLabel(item);
            final checked = _tempSelected.contains(item);
            return CheckboxListTile(
              value: checked,
              title: Text(label),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (val) => _onItemCheckedChange(item, val ?? false),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _tempSelected),
          child: const Text('OK'),
        ),
      ],
    );
  }


}

