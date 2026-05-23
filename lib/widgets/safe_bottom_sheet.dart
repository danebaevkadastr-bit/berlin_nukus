import 'package:flutter/material.dart';

/// Bottom sheet ichida "bottom overflowed" oldini olish.
class SafeBottomSheet {
  SafeBottomSheet._();

  static Widget keyboardPadding(BuildContext context, Widget child) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: child,
    );
  }

  /// Formalar: klaviatura ochilganda scroll.
  static Widget scrollable({
    required BuildContext context,
    required Widget child,
    double maxHeightFactor = 0.92,
  }) {
    return keyboardPadding(
      context,
      ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * maxHeightFactor,
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: child,
        ),
      ),
    );
  }

  /// Ro'yxat + pastki tugma: aniq balandlik (Column ichida Expanded ishlaydi).
  static Widget fixedHeight({
    required BuildContext context,
    required Widget child,
    double heightFactor = 0.85,
  }) {
    return keyboardPadding(
      context,
      SizedBox(
        height: MediaQuery.sizeOf(context).height * heightFactor,
        child: child,
      ),
    );
  }
}
