import 'package:flutter/material.dart';

/// Pure logic, unit-testable without standing up a widget tree (see
/// test/unit/staleness_test.dart) — spec.md FR-009: shown data may be
/// stale (e.g. no current connectivity) rather than presented as live.
/// 60s default matches SC-001's own 60s budget — well past the 10s
/// auto-refresh interval (research.md §10), so this only fires once a
/// refresh has genuinely stopped succeeding, not on ordinary jitter
/// between polls.
bool isStale(DateTime lastFetched, {DateTime? now, Duration threshold = const Duration(seconds: 60)}) {
  final reference = now ?? DateTime.now();
  return reference.difference(lastFetched) > threshold;
}

/// Renders only when the data on screen may be stale — either the last
/// refresh attempt failed outright, or too long has passed since the
/// last successful one. Deliberately quiet the rest of the time (no
/// permanent "last updated" chrome), since FR-009 only requires flagging
/// staleness, not narrating every successful refresh.
class StalenessBanner extends StatelessWidget {
  const StalenessBanner({super.key, required this.lastFetched, required this.lastFetchFailed});

  final DateTime? lastFetched;
  final bool lastFetchFailed;

  @override
  Widget build(BuildContext context) {
    final stale = lastFetchFailed || (lastFetched != null && isStale(lastFetched!));
    if (!stale) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.errorContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.wifi_off, size: 16, color: Theme.of(context).colorScheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Showing possibly outdated data — could not refresh.',
              style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
