import 'package:flutter/material.dart';

class ElevatedIconButton extends StatefulWidget {
  final Widget child;

  final Function()? onPressed;

  final double? width;

  final double? height;

  final Icon? icon;

  final Color? backgroundColor;

  const ElevatedIconButton({
    super.key,
    required this.child,
    this.onPressed,
    this.width,
    this.height,
    this.icon,
    this.backgroundColor,
  });

  @override
  State<ElevatedIconButton> createState() => _ElevatedIconButtonState();
}

class _ElevatedIconButtonState extends State<ElevatedIconButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height ?? 45,
      child: ElevatedButton(
        onPressed: widget.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.backgroundColor,
        ),
        child:
            widget.icon != null
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [widget.icon!, widget.child],
                )
                : widget.child,
      ),
    );
  }
}
