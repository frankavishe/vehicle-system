import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/autoserve_api.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/service_request.dart';

final myRequestsProvider = FutureProvider.autoDispose<List<ServiceRequestDto>>((ref) {
  return ref.watch(autoserveApiProvider).listServiceRequests();
});

class MyRequestsScreen extends ConsumerWidget {
  const MyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(myRequestsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(myRequestsProvider),
      child: requests.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(myRequestsProvider),
            child: const Text('Could not load requests — tap to retry'),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return ListView(
              children: const [
                Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('No requests yet — request a mechanic or towing above.')),
                ),
              ],
            );
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final r = items[i];
              return ListTile(
                leading: Icon(r.serviceType == ServiceType.mechanic ? Icons.build : Icons.local_shipping),
                title: Text(r.serviceType == ServiceType.mechanic ? 'Mechanic' : 'Towing'),
                subtitle: Text(r.problemDescription ?? 'No description'),
                trailing: Chip(
                  label: Text(r.status.name),
                  backgroundColor: statusColor(_wireStatus(r.status)).withValues(alpha: 0.15),
                ),
                onTap: () => context.go('/customer/requests/${r.id}'),
              );
            },
          );
        },
      ),
    );
  }

  String _wireStatus(ServiceStatus status) => serviceStatusWireValue(status);
}
