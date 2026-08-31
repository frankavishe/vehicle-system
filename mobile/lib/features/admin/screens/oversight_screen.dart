import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/autoserve_api.dart';
import '../../../features/notifications/screens/notifications_screen.dart';
import '../../../shared/models/admin_analytics_dto.dart';
import '../widgets/staleness_banner.dart';

final _analyticsProvider = FutureProvider.autoDispose<AdminAnalyticsDto>((ref) {
  return ref.watch(autoserveApiProvider).getAnalytics();
});

/// SC-003: an admin can identify a flagged abnormal condition within 5s
/// of opening this view. Auto-refreshes every 10s while visible (same
/// pattern as DisputeListScreen, research.md §10).
class OversightScreen extends ConsumerStatefulWidget {
  const OversightScreen({super.key});

  @override
  ConsumerState<OversightScreen> createState() => _OversightScreenState();
}

class _OversightScreenState extends ConsumerState<OversightScreen> {
  Timer? _timer;
  DateTime? _lastFetched;
  bool _lastFetchFailed = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _refresh() => ref.invalidate(_analyticsProvider);

  @override
  Widget build(BuildContext context) {
    final analytics = ref.watch(_analyticsProvider);
    analytics.whenData((_) {
      _lastFetched = DateTime.now();
      _lastFetchFailed = false;
    });
    if (analytics.hasError) _lastFetchFailed = true;

    return Column(
      children: [
        StalenessBanner(lastFetched: _lastFetched, lastFetchFailed: _lastFetchFailed),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: analytics.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: TextButton(
                        onPressed: _refresh,
                        child: const Text('Could not load oversight data — tap to retry'),
                      ),
                    ),
                  ),
                ],
              ),
              data: (a) => ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (a.hasAlert)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber, color: Theme.of(context).colorScheme.onErrorContainer),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Abnormal condition flagged: '
                              '${a.failedNotificationsRecent} failed notification(s), '
                              '${a.failedPaymentsRecent} failed payment(s) in the last 24h.',
                              style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                            ),
                          ),
                        ],
                      ),
                    ),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.6,
                    children: [
                      _StatTile(label: 'Open disputes', value: '${a.openDisputes}'),
                      _StatTile(label: 'Active providers', value: '${a.activeProviders}'),
                      _StatTile(
                        label: 'Active jobs',
                        value: '${a.serviceRequestsByStatus.entries.where((e) => e.key != 'COMPLETED' && e.key != 'CANCELLED').fold<int>(0, (sum, e) => sum + e.value)}',
                      ),
                      _StatTile(
                        label: 'Recent orders',
                        value: '${a.ordersByStatus.values.fold<int>(0, (sum, v) => sum + v)}',
                      ),
                      _StatTile(label: 'Revenue', value: a.revenue),
                    ],
                  ),
                  const SizedBox(height: 24),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    tooltip: 'Notifications',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          appBar: AppBar(title: const Text('Notifications')),
                          body: const NotificationsScreen(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
