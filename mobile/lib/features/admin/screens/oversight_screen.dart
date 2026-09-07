import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/autoserve_api.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/notifications/screens/notifications_screen.dart';
import '../../../shared/models/admin_analytics_dto.dart';
import '../../../shared/widgets/stat_tile.dart';
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
                        color: Theme.of(context).extension<AppSemanticColors>()!.stopBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber,
                            color: Theme.of(context).extension<AppSemanticColors>()!.stop,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Abnormal condition flagged: '
                              '${a.failedNotificationsRecent} failed notification(s), '
                              '${a.failedPaymentsRecent} failed payment(s) in the last 24h.',
                              style: TextStyle(color: Theme.of(context).extension<AppSemanticColors>()!.stop),
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
                      StatTile(label: 'Open disputes', value: '${a.openDisputes}'),
                      StatTile(label: 'Active providers', value: '${a.activeProviders}'),
                      StatTile(
                        label: 'Active jobs',
                        value:
                            '${a.serviceRequestsByStatus.entries.where((e) => e.key != 'COMPLETED' && e.key != 'CANCELLED').fold<int>(0, (sum, e) => sum + e.value)}',
                      ),
                      StatTile(
                        label: 'Recent orders',
                        value: '${a.ordersByStatus.values.fold<int>(0, (sum, v) => sum + v)}',
                      ),
                      StatTile(label: 'Revenue', value: a.revenue, highlight: true),
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
