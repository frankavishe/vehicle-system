import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/autoserve_api.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/service_request.dart';

final availabilityProvider = StateProvider<bool>((ref) => false);

final jobListProvider =
    FutureProvider.autoDispose.family<List<ServiceRequestDto>, String>((ref, role) {
  // GET /service-requests with no status filter returns pending
  // same-type jobs + this provider's own accepted+ jobs (server-side
  // scoping, apps/dispatch/views.py's ServiceRequestListCreateView.get).
  return ref.watch(autoserveApiProvider).listServiceRequests();
});

class JobListScreen extends ConsumerWidget {
  const JobListScreen({super.key, required this.role});
  final String role;

  Future<void> _toggleAvailability(WidgetRef ref, bool value) async {
    ref.read(availabilityProvider.notifier).state = value;
    await ref.read(autoserveApiProvider).setAvailability(value);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(jobListProvider(role));
    final available = ref.watch(availabilityProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(jobListProvider(role)),
      child: ListView(
        children: [
          SwitchListTile(
            title: const Text('Available for new jobs'),
            subtitle: Text(available ? 'Nearby customers can dispatch to you' : 'You will not receive job alerts'),
            value: available,
            onChanged: (v) => _toggleAvailability(ref, v),
          ),
          const Divider(height: 1),
          jobs.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: TextButton(
                  onPressed: () => ref.invalidate(jobListProvider(role)),
                  child: const Text('Could not load jobs — tap to retry'),
                ),
              ),
            ),
            data: (items) {
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('No jobs right now.')),
                );
              }
              return Column(
                children: [
                  for (final job in items)
                    ListTile(
                      leading: const Icon(Icons.build_circle_outlined),
                      title: Text(job.problemDescription ?? 'No description'),
                      subtitle: Text(
                        '${job.pickupLocation.lat.toStringAsFixed(4)}, ${job.pickupLocation.lng.toStringAsFixed(4)}',
                      ),
                      trailing: Chip(
                        label: Text(job.status.name),
                        backgroundColor:
                            statusColor(serviceStatusWireValue(job.status)).withValues(alpha: 0.15),
                      ),
                      onTap: () => context.go('/${role.toLowerCase()}/jobs/${job.id}'),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
