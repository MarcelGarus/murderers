import 'dart:async';

import 'package:flutter/material.dart';

import 'theme.dart';

/// A button that can morph into a loading spinner.
/// 
/// This button can be given a child or a text to display. The passed
/// [onPressed] callback is called if the button is pressed. In contrast to the
/// normal built-in button, this button morphs into a loading spinner if the
/// passed callback is asynchronous (aka it returns a [Future]).
/// You can also pass in an [onSuccess] and an [onError] listener to listen to
/// the [onPressed]'s [then] and [catchError] events.
/// If the Future fails, the button restores itself to the normal state.
class Button<T> extends StatefulWidget {
  Button({
    this.child,
    this.text,
    this.isRaised = true,
    @required this.onPressed,
    this.onSuccess,
    this.onError,
  }) :
      assert(child != null || text != null),
      assert(isRaised != null),
      assert(onPressed != null);

  final Widget child;
  final String text;
  final bool isRaised;
  final Function() onPressed;
  final Function(T result) onSuccess;
  final Function(dynamic error) onError;

  _ButtonState createState() => _ButtonState<T>();
}

class _ButtonState<T> extends State<Button>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;

  void onPressed() {
    final result = widget.onPressed();

    if (result is Future) {
      setState(() => _isLoading = true);
      result.then((res) {
        if (widget.onSuccess != null) widget.onSuccess(res);
      }).catchError((error) {
        setState(() => _isLoading = false);
        if (widget.onError != null) widget.onError(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = MyTheme.of(context);

    return RawMaterialButton(
      onPressed: _isLoading ? () {} : onPressed,
      fillColor: widget.isRaised ? theme.raisedButtonFillColor : null,
      highlightColor: Colors.black.withOpacity(0.08),
      splashColor: _isLoading ? Colors.transparent
        : widget.isRaised ? Colors.black26
        : theme.flatButtonColor.withOpacity(0.3),
      elevation: widget.isRaised ? 2 : 0,
      highlightElevation: widget.isRaised ? 2 : 0,
      shape: _isLoading
        ? CircleBorder()
        : RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      animationDuration: Duration(milliseconds: 200),
      child: Container(
        width: _isLoading ? 48 : null,
        height: _isLoading ? 48 : null,
        child: _isLoading ? buildLoadingContent(theme) : buildIdleContent(theme)
      ),
    );
  }

  Widget buildLoadingContent(MyThemeData theme) {
    return Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            widget.isRaised ? theme.raisedButtonTextColor : theme.flatButtonColor
          ),
        )
      )
    );
  }

  Widget buildIdleContent(MyThemeData theme) {
    return widget.child ?? Padding(
      padding: EdgeInsets.all(16),
      child: Text(widget.text,
        textScaleFactor: 1.2,
        style: TextStyle(
          color: widget.isRaised ? theme.raisedButtonTextColor : theme.flatButtonColor,
          fontFamily: 'Signature',
        )
      )
    );
  }
}
