import 'package:flutter/material.dart';

/// Shared FR-007 confirmation gate — every mutating admin action
/// (dispute resolve, suspend/reinstate, manual payout trigger) routes
/// through this one widget rather than a bespoke `showDialog` per
/// screen, so SC-004's "100% require confirmation" claim is provable by
/// construction (one code path), not by auditing every screen
/// individually (research.md §9).
///
/// Returns `true` if the admin confirmed, `false`/`null` otherwise.
Future<bool> confirmAdminAction(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  bool destructive = false,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error)
              : null,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
