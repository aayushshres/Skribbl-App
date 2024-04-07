import 'package:flutter/material.dart';
import 'package:skribbl_app/core/theme/app_pallete.dart';

class DropdownWidget extends StatefulWidget {
  final String hintText;
  final List itemList;
  const DropdownWidget({
    super.key,
    required this.hintText,
    required this.itemList,
  });

  @override
  State<DropdownWidget> createState() => _DropdownWidgetState();
}

class _DropdownWidgetState extends State<DropdownWidget> {
  String? selectedValue;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            width: 3,
            color: AppPallete.borderColor,
          ),
          borderRadius: BorderRadius.circular(10)),
      child: DropdownButton(
        focusColor: AppPallete.transparentColor,
        dropdownColor: AppPallete.backgroundColor,
        hint: Text(widget.hintText),
        value: selectedValue,
        isExpanded: true,
        underline: const SizedBox(),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
        onChanged: (newValue) {
          setState(() {
            selectedValue = newValue.toString();
          });
        },
        items: widget.itemList.map((valueItem) {
          return DropdownMenuItem(
            value: valueItem,
            child: Text(valueItem),
          );
        }).toList(),
      ),
    );
  }
}
