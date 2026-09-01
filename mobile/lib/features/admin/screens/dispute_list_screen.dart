import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/autoserve_api.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/dispute_dto.dart';
import '../widgets/staleness_banner.dart';

final _openDisputesProvider = FutureProvider.autoDispose<List<DisputeDto>>((ref) {
  return ref.watch(autoserveApiProvider).listDisputes(status: 'OPEN');
});

/// SC-001 (resolve a dispute in <60s) and SC-005 (cross-surface
/// consistency within 5s) — auto-refreshes every 10s while visible, on
/// top of pull-to-refresh, matching the existing 10s poll precedent
/// (web's FleetMap/AdminMap) rather than requiring the admin to
/// remember to refresh (research.md §10).
class DisputeListScreen extends ConsumerStatefulWidget {
  const DisputeListScreen({super.key});

  @override
  ConsumerState<DisputeListScreen> createState() => _DisputeListScreenState();
}

class _DisputeListScreenState extends ConsumerState<DisputeListScreen> {
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

  void _refresh() => ref.invalidate(_openDisputesProvider);

  @override
  Widget build(BuildContext context) {
    final disputes = ref.watch(_openDisputesProvider);

    disputes.whenData((_) {
      _lastFetched = DateTime.now();
      _lastFetchFailed = false;
    });
    if (disputes.hasError) _lastFetchFailed = true;

    return Column(
      children: [
        StalenessBanner(lastFetched: _lastFetched, lastFetchFailed: _lastFetchFailed),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: disputes.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: TextButton(
                        onPressed: _refresh,
                        child: const Text('Could not load disputes — tap to retry'),
                      ),
                    ),
                  ),
                ],
              ),
              data: (items) {
                if (items.isEmpty) {
                  return ListView(
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: Text('Nothing pending — no open disputes.')),
                      ),
                    ],
                  );
                }
                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final d = items[i];
                    final job = d.serviceRequestSummary;
                    return ListTile(
                      leading: const Icon(Icons.report_problem_outlined),
                      title: Text(
                        job == null
                            ? 'Dispute'
                            : '${job.serviceType == 'MECHANIC' ? 'Mechanic' : 'Towing'} job — ${job.customerName ?? 'unknown customer'}',
                      ),
                      subtitle: Text(d.reason ?? 'No reason given', maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: Chip(
                        label: Text(d.status.name.toUpperCase()),
                        backgroundColor: statusColor(d.status == DisputeStatus.open ? 'PENDING' : 'COMPLETED')
                            .withValues(alpha: 0.15),
                      ),
                      onTap: () => context.push('/admin/disputes/${d.id}'),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
