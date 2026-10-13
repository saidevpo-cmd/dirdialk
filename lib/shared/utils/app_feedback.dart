import 'package:flutter/material.dart';

import '../../domain/models/app_error.dart';

/// Consistent, accessible user feedback for completed operations.
///
/// Screens must never show a success message when the underlying repository
/// call failed — use [fromResult] or check the [Result] before calling
/// [success].
class AppFeedback {
  const AppFeedback._();

  static void success(BuildContext context, String message) {
    _show(context, message, isError: false);
  }

  static void failure(BuildContext context, String message) {
    _show(context, message, isError: true);
  }

  static void error(BuildContext context, AppError error) {
    _show(context, error.message, isError: true);
  }

  /// Shows [successMessage] on `Success`, otherwise the repository error.
  ///
  /// Returns `true` when the operation succeeded so callers can update state.
  static bool fromResult(
    BuildContext context,
    Result<Object?> result, {
    required String successMessage,
  }) {
    switch (result) {
      case Success():
        success(context, successMessage);
        return true;
      case Failure(:final error):
        AppFeedback.error(context, error);
        return false;
    }
  }

  static void _show(
    BuildContext context,
    String message, {
    required bool isError,
  }) {
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    final scheme = Theme.of(context).colorScheme;
    final background = isError ? scheme.errorContainer : scheme.inverseSurface;
    final foreground = isError ? scheme.onErrorContainer : scheme.onInverseSurface;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                size: 20,
                color: foreground,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(message, style: TextStyle(color: foreground))),
            ],
          ),
          backgroundColor: background,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
  }
}
