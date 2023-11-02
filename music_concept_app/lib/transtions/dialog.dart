import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

Future<T?> dialogKeyboardBuilder<T>(
    BuildContext context, Offset currentPosition, Widget content) {
  final dx = currentPosition.dx / MediaQuery.of(context).size.width;
  final dy = (currentPosition.dy / MediaQuery.of(context).size.height);
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Label",
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      var tween = CurveTween(curve: Curves.easeOutCirc).animate(animation);
      return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            return _DialogContent(
              dx: dx,
              dy: dy,
              tween: tween,
              child: child,
            );
          });
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return KeyBoardDialogBuilder(
        content: content,
      );
    },
  );
}

Future<T?> dialogBuilder<T>(
    BuildContext context, Offset currentPosition, Widget content) {
  final dx = currentPosition.dx / MediaQuery.of(context).size.width;
  final dy = (currentPosition.dy / MediaQuery.of(context).size.height);
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Label",
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      var tween = CurveTween(curve: Curves.easeOutCirc).animate(animation);
      return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            return _DialogContent(
              dx: dx,
              dy: dy,
              tween: tween,
              child: child,
            );
          });
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return Align(
        alignment: FractionalOffset.center,
        child: content,
      );
    },
  );
}

class KeyBoardDialogBuilder extends StatefulWidget {
  const KeyBoardDialogBuilder({
    super.key,
    required this.content,
  });

  final Widget content;

  @override
  State<KeyBoardDialogBuilder> createState() => KeyBoardDialogBuilderState();
}

class KeyBoardDialogBuilderState extends State<KeyBoardDialogBuilder> {
  final _keyboardVisibilityController = KeyboardVisibilityController();
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _keyboardVisibilityController.onChange.listen((event) {
      if (mounted) {
        setState(() {
          _isKeyboardVisible = event;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: _isKeyboardVisible
          ? Tween<double>(begin: 0.0, end: 1.0)
          : Tween<double>(begin: 1.0, end: 0.0),
      builder: (context, value, child) {
        return Align(
          alignment: FractionalOffset.lerp(
            FractionalOffset.center,
            FractionalOffset(
              0.5,
              100 / MediaQuery.of(context).size.height,
            ),
            value,
          )!,
          child: child,
        );
      },
      child: widget.content,
    );
  }
}

class _DialogContent extends StatelessWidget {
  const _DialogContent({
    required this.dx,
    required this.dy,
    required this.tween,
    required this.child,
  });

  final double dx;
  final double dy;
  final Animation<double> tween;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: FractionalOffset(dx, dy),
      transform: Matrix4.identity()..scale(tween.value),
      child: child,
    );
  }
}
