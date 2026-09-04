import 'package:flutter/material.dart';

/// Shows [message] as a snack bar, replacing any that is already up.
void showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// `listenWhen` predicate: fires when a new error message appears.
bool errorAppeared(String? previous, String? current) =>
    current != null && previous != current;
