import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/api/autoserve_api.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/parts_sourcing_request.dart';
import '../../../shared/models/service_request.dart';
import 'my_requests_screen.dart';

final _requestDetailProvider =
    FutureProvider.autoDispose.family<ServiceRequestDto, String>((ref, id) {
  return ref.watch(autoserveApiProvider).getServiceRequest(id);
});

final _partsRequestsProvider =
    FutureProvider.autoDispose.family<List<PartsSourcingRequestDto>, String>((ref, id) {
  return ref.watch(autoserveApiProvider).listPartsRequests(id);
});

/// A still-open request (not yet completed/cancelled) can always be
/// cancelled by its customer — PENDING included, per
/// apps/dispatch/services/transitions.py's ALLOWED_TRANSITIONS.
bool _isCancellable(ServiceStatus status) =>
    status != ServiceStatus.completed && status != ServiceStatus.cancelled;

/// Phase 4 (PLAN.md §5.2): tracking is only meaningful once a provider is
/// actively working the job — before ACCEPTED there's no one to track,
/// after COMPLETED/CANCELLED there's nothing live left to show.
bool _isTrackable(ServiceStatus status) => switch (status) {
      ServiceStatus.accepted || ServiceStatus.enRoute || ServiceStatus.inProgress => true,
      _ => false,
    };

class RequestDetailScreen extends ConsumerWidget {
  const RequestDetailScreen({super.key, required this.requestId});

  final String requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(_requestDetailProvider(requestId));

    return Scaffold(
      appBar: AppBar(title: const Text('Request details')),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(_requestDetailProvider(requestId)),
            child: const Text('Could not load this request — tap to retry'),
          ),
        ),
        data: (sr) => _RequestDetailBody(sr: sr),
      ),
    );
  }
}

class _RequestDetailBody extends ConsumerWidget {
  const _RequestDetailBody({required this.sr});
  final ServiceRequestDto sr;

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    await ref.read(autoserveApiProvider).updateServiceRequestStatus(sr.id, ServiceStatus.cancelled);
    ref.invalidate(_requestDetailProvider(sr.id));
    ref.invalidate(myRequestsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partsRequests = sr.serviceType == ServiceType.mechanic
        ? ref.watch(_partsRequestsProvider(sr.id))
        : null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Icon(sr.serviceType == ServiceType.mechanic ? Icons.build : Icons.local_shipping),
            const SizedBox(width: 8),
            Text(
              sr.serviceType == ServiceType.mechanic ? 'Mechanic' : 'Towing',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Spacer(),
            Chip(
              label: Text(sr.status.name),
              backgroundColor: statusColor(serviceStatusWireValue(sr.status)).withValues(alpha: 0.15),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (sr.problemDescription != null) ...[
          Text('Problem', style: Theme.of(context).textTheme.labelLarge),
          Text(sr.problemDescription!),
          const SizedBox(height: 16),
        ],
        if (sr.provider != null) ...[
          Text('Provider', style: Theme.of(context).textTheme.labelLarge),
          Text('${sr.provider!.fullName} · ${sr.provider!.phone}'),
          const SizedBox(height: 16),
        ],
        Text('Pickup', style: Theme.of(context).textTheme.labelLarge),
        Text('${sr.pickupLocation.lat.toStringAsFixed(5)}, ${sr.pickupLocation.lng.toStringAsFixed(5)}'),
        if (sr.dropoffLocation != null) ...[
          const SizedBox(height: 16),
          Text('Drop-off', style: Theme.of(context).textTheme.labelLarge),
          Text('${sr.dropoffLocation!.lat.toStringAsFixed(5)}, ${sr.dropoffLocation!.lng.toStringAsFixed(5)}'),
        ],
        if (_isTrackable(sr.status)) ...[
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.push('/customer/tracking/${sr.id}'),
            icon: const Icon(Icons.map),
            label: const Text('Track live location'),
          ),
        ],
        if (_isCancellable(sr.status)) ...[
          const SizedBox(height: 24),
          OutlinedButton(onPressed: () => _cancel(context, ref), child: const Text('Cancel request')),
        ],
        if (partsRequests != null) ...[
          const Divider(height: 40),
          Text('Parts requested by your mechanic', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          partsRequests.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => const Text('Could not load parts requests.'),
            data: (items) => items.isEmpty
                ? const Text('None yet.')
                : Column(children: [for (final p in items) _PartsRequestTile(psr: p, serviceRequestId: sr.id)]),
          ),
        ],
      ],
    );
  }
}

class _PartsRequestTile extends ConsumerStatefulWidget {
  const _PartsRequestTile({required this.psr, required this.serviceRequestId});
  final PartsSourcingRequestDto psr;
  final String serviceRequestId;

  @override
  ConsumerState<_PartsRequestTile> createState() => _PartsRequestTileState();
}

class _PartsRequestTileState extends ConsumerState<_PartsRequestTile> {
  bool _busy = false;

  Future<void> _respond(bool approved) async {
    setState(() => _busy = true);
    try {
      await ref.read(autoserveApiProvider).approvePartsRequest(widget.psr.id, approved);
      ref.invalidate(_partsRequestsProvider(widget.serviceRequestId));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _buyNow() async {
    setState(() => _busy = true);
    try {
      final orderId = await ref.read(autoserveApiProvider).convertPartsRequestToOrder(widget.psr.id);
      // Hands off to Phase 2's hosted checkout instead of a native Dart
      // payment UI — flagged decision, PLAN §7 item 9.
      final url = Uri.parse('${_storefrontBaseUrl()}/orders/$orderId');
      await launchUrl(url, mode: LaunchMode.externalApplication);
      ref.invalidate(_partsRequestsProvider(widget.serviceRequestId));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _storefrontBaseUrl() =>
      const String.fromEnvironment('STOREFRONT_BASE_URL', defaultValue: 'http://10.0.2.2:3000');

  @override
  Widget build(BuildContext context) {
    final psr = widget.psr;
    return Card(
      child: ListTile(
        title: Text('Qty ${psr.quantity}'),
        subtitle: Text('Status: ${psr.status.name}'),
        trailing: _busy
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : switch (psr.status) {
                PartsSourcingStatus.pending => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _respond(true),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _respond(false),
                      ),
                    ],
                  ),
                PartsSourcingStatus.approved =>
                  TextButton(onPressed: _buyNow, child: const Text('Buy now')),
                _ => const SizedBox.shrink(),
              },
      ),
    );
  }
}
