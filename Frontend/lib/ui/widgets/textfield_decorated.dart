import 'package:flutter/material.dart';

/// Text input widget
class TextFieldDecorated extends StatefulWidget {
  final String? labelText;

  final String? hintText;

  final TextEditingController? controller;

  final bool? obscureText;

  final Widget? suffix;

  final bool? enabled;

  final double? width;

  final double? height;

  final int? maxLines;

  final int? minLines;

  final Widget? suffixIcon;

  final Function(String)? onSubmitted;

  final Function(String)? onChanged;

  const TextFieldDecorated({
    super.key,
    this.labelText,
    this.hintText,
    this.controller,
    this.enabled,
    this.obscureText,
    this.suffix,
    this.width,
    this.height,
    this.maxLines,
    this.minLines,
    this.suffixIcon,
    this.onSubmitted,
    this.onChanged,
  });

  @override
  State<TextFieldDecorated> createState() => _TextFieldDecoratedState();
}

class _TextFieldDecoratedState extends State<TextFieldDecorated> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15), // rounded corners
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.obscureText ?? false,
        enabled: widget.enabled ?? true,
        maxLines: widget.obscureText != null ? 1 : widget.maxLines,
        minLines: widget.obscureText != null ? 1 : widget.minLines,
        onSubmitted: (text) {
          if (widget.onSubmitted != null) {
            widget.onSubmitted!(text);
          }
        },
        onChanged: (text) {
          if (widget.onChanged != null) {
            widget.onChanged!(text);
          }
        },
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          suffix: widget.suffix,
          suffixIcon: widget.suffixIcon,
        ),
      ),
    );
  }
}
