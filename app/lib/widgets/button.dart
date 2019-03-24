import 'dart:async';

import 'package:flutter/material.dart';

import 'theme.dart';

/// A button that can morph into a loading spinner.
///
/// This button can be given a child or a text to display. The passed
/// [onPressed] callback is called if the button is pressed. In contrast to the
/// normal built-in button, this button morphs into a loading spinner if the
/// passed callback is asynchronous (if it returns a [Future]).
/// If the future throws an error, the button stops spinning (so the user can
/// try again) and the [onError] callback is called with the caught error.
/// Otherwise the [onSuccess] callback is called with the result. The callback
/// might return a [Future<bool>], causing the button to await that future and
/// stop spinning if it evaluates to [false]. Otherwise, it just continues to
/// spin endlessly.
class Button<T> extends StatefulWidget {
  Button({
    @required this.child,
    this.isRaised = true,
    @required this.onPressed,
    this.onSuccess,
    this.onError,
  })  : assert(child != null),
        assert(isRaised != null),
        assert(onPressed != null);

  final Widget child;
  final bool isRaised;
  final FutureOr<T> Function() onPressed;
  final dynamic Function(T result) onSuccess;
  final void Function(dynamic error) onError;

  /// Creates a button that only displays some text.
  Button.text(
    String text, {
    this.isRaised = true,
    @required this.onPressed,
    this.onSuccess,
    this.onError,
  })  : assert(text != null),
        assert(onPressed != null),
        child = Padding(
          padding: EdgeInsets.all(16),
          child: _ButtonText(text, isRaised: isRaised),
        );

  /// Creates a button that displays text next to an icon.
  Button.icon({
    @required Widget icon,
    @required String text,
    this.isRaised = true,
    @required this.onPressed,
    this.onSuccess,
    this.onError,
  })  : assert(icon != null),
        assert(text != null),
        assert(onPressed != null),
        child = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              icon,
              SizedBox(width: 16),
              _ButtonText(text, isRaised: isRaised),
            ],
          ),
        );

  _ButtonState createState() => _ButtonState<T>();
}

class _ButtonState<T> extends State<Button> {
  var _isLoading = false;

  void _onPressed() {
    final result = widget.onPressed();

    // If the callback is asynchronous, morph the button into a loading spinner.
    if (result is Future) {
      setState(() => _isLoading = true);

      // If the widget has an [onSuccess] or [onError] callback, call it at
      // appropriate times.
      result.then(_onSuccess).catchError((error) {
        setState(() => _isLoading = false);
        if (widget.onError != null) widget.onError(error);
      });
    }
  }

  void _onSuccess(T result) async {
    if (widget.onSuccess == null) return;

    final successResult = widget.onSuccess(result);
    if (successResult is Future<bool>) {
      final bool keepSpinning = await successResult;
      _isLoading = keepSpinning;
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = MyTheme.of(context);

    return RawMaterialButton(
      // Do not handle touch events if the button is already loading.
      onPressed: _isLoading ? () {} : _onPressed,
      fillColor: widget.isRaised ? theme.raisedButtonFillColor : null,
      highlightColor: Colors.black.withOpacity(0.08),
      splashColor: _isLoading
          ? Colors.transparent
          : widget.isRaised
              ? Colors.black26
              : theme.flatButtonColor.withOpacity(0.3),
      elevation: widget.isRaised ? 2 : 0,
      highlightElevation: widget.isRaised ? 2 : 0,
      shape: _isLoading
          ? const CircleBorder()
          : RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      animationDuration: Duration(milliseconds: 200),
      child: Container(
        width: _isLoading ? 52 : null,
        height: _isLoading ? 52 : null,
        child: _isLoading ? _buildLoadingContent(theme) : widget.child,
      ),
    );
  }

  Widget _buildLoadingContent(MyThemeData theme) {
    final color =
        widget.isRaised ? theme.raisedButtonTextColor : theme.flatButtonColor;

    return Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(color),
        ),
      ),
    );
  }
}

/// Text that uses the appropriate text color from MyTheme when rendered.
class _ButtonText extends StatelessWidget {
  _ButtonText(this.text, {this.isRaised = true});

  final String text;
  final bool isRaised;

  @override
  Widget build(BuildContext context) {
    var theme = MyTheme.of(context);

    return Text(
      text,
      style: TextStyle(
        color: isRaised ? theme.raisedButtonTextColor : theme.flatButtonColor,
        fontFamily: 'Signature',
        fontSize: 16,
      ),
    );
  }
}
