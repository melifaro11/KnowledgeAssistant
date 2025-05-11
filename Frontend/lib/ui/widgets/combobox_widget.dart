import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

/// Stylized ComboBox with a search
class ComboBox<T> extends StatefulWidget {
  final Widget? hint;

  final List<DropdownMenuItem<T>>? items;

  final Function(T?)? onChanged;

  final T? value;

  final double? width;

  final double? height;

  final double? maxHeight;

  final List<Widget> Function(BuildContext)? selectedItemBuilder;

  final bool showSearch;

  const ComboBox({
    super.key,
    this.hint,
    this.items,
    this.onChanged,
    this.value,
    this.width,
    this.height,
    this.maxHeight,
    this.selectedItemBuilder,
    this.showSearch = true,
  });

  @override
  State<ComboBox<T>> createState() => _ComboBoxState<T>();
}

class _ComboBoxState<T> extends State<ComboBox<T>> {
  final TextEditingController _searchEditingController =
      TextEditingController();

  @override
  void dispose() {
    _searchEditingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<T>(
        isExpanded: false,
        hint: widget.hint,
        items: widget.items,
        value: widget.value,
        selectedItemBuilder: widget.selectedItemBuilder,
        onChanged: (value) {
          if (widget.onChanged != null) {
            widget.onChanged!(value);
          }
        },
        buttonStyleData: ButtonStyleData(
          height: widget.height,
          width: widget.width,
          padding: const EdgeInsets.only(left: 14, right: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Theme.of(context).colorScheme.primary),
          ),
        ),
        iconStyleData: const IconStyleData(
          icon: Icon(Icons.keyboard_arrow_down),
          iconSize: 14,
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: widget.maxHeight,
          width: widget.width,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
          offset: const Offset(-20, 0),
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(40),
            thickness: WidgetStatePropertyAll(6),
            thumbVisibility: WidgetStatePropertyAll(true),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 40,
          padding: EdgeInsets.only(left: 14, right: 14),
        ),
        dropdownSearchData:
            widget.showSearch == true
                ? DropdownSearchData(
                  searchController: _searchEditingController,
                  searchInnerWidgetHeight: 50,
                  searchInnerWidget: Container(
                    height: 50,
                    padding: const EdgeInsets.only(
                      top: 8,
                      bottom: 4,
                      right: 8,
                      left: 8,
                    ),
                    child: TextFormField(
                      expands: true,
                      maxLines: null,
                      controller: _searchEditingController,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        hintText: 'Search for an item...',
                        hintStyle: const TextStyle(fontSize: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  searchMatchFn: (item, searchValue) {
                    return item.value.toString().contains(searchValue);
                  },
                )
                : null,
        onMenuStateChange: (isOpen) {
          if (!isOpen) {
            _searchEditingController.clear();
          }
        },
      ),
    );
  }
}
