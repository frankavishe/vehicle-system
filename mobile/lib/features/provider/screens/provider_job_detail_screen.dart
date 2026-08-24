import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/autoserve_api.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/service_request.dart';
import '../../../shared/models/spare_part_summary.dart';
import 'job_list_screen.dart';

final _jobDetailProvider = FutureProvider.autoDispose.family<ServiceRequestDto, String>((ref, id) {
  return ref.watch(autoserveApiProvider).getServiceRequest(id);
});

/// Client-side mirror of the role half of
/// apps/dispatch/services/transitions.py's role map — provider-reachable
/// targets only (this screen never offers CANCELLED-by-customer options).
const _providerTargets = [ServiceStatus.enRoute, ServiceStatus.inProgress, ServiceStatus.completed];

/// Phase 4 (PLAN.md §5.2) — mirrors request_detail_screen.dart's
/// _isTrackable; the provider side also drives publishing its own
/// location once here.
bool _isTrackable(ServiceStatus status) => switch (status) {
      ServiceStatus.accepted || ServiceStatus.enRoute || ServiceStatus.inProgress => true,
      _ => false,
    };

class ProviderJobDetailScreen extends ConsumerWidget {
  const ProviderJobDetailScreen({super.key, required this.requestId, required this.role});
  final String requestId;
  final String role; // MECHANIC | RECOVERY

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(_jobDetailProvider(requestId));

    return Scaffold(
      appBar: AppBar(title: const Text('Job details')),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(_jobDetailProvider(requestId)),
            child: const Text('Could not load this job — tap to retry'),
          ),
        ),
        data: (sr) => _JobDetailBody(sr: sr, role: role),
      ),
    );
  }
}

class _JobDetailBody extends ConsumerStatefulWidget {
  const _JobDetailBody({required this.sr, required this.role});
  final ServiceRequestDto sr;
  final String role;

  @override
  ConsumerState<_JobDetailBody> createState() => _JobDetailBodyState();
}

class _JobDetailBodyState extends ConsumerState<_JobDetailBody> {
  bool _busy = false;
  String? _error;

  Future<void> _accept() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await ref.read(autoserveApiProvider).acceptServiceRequest(widget.sr.id);
      if (result == null) {
        setState(() => _error = 'Another provider already accepted this job.');
      }
      ref.invalidate(_jobDetailProvider(widget.sr.id));
      ref.invalidate(jobListProvider(widget.role));
    } on DioException catch (e) {
      setState(() => _error = e.response?.data?['detail']?.toString() ?? 'Could not accept job.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _advance(ServiceStatus target) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(autoserveApiProvider).updateServiceRequestStatus(widget.sr.id, target);
      ref.invalidate(_jobDetailProvider(widget.sr.id));
      ref.invalidate(jobListProvider(widget.role));
    } on DioException catch (e) {
      setState(() => _error = e.response?.data?['detail']?.toString() ?? 'Could not update status.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sr = widget.sr;
    final reachable = allowedStatusTransitions[sr.status] ?? {};

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Text(
              sr.serviceType == ServiceType.mechanic ? 'Mechanic job' : 'Towing job',
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
        if (sr.customer != null) ...[
          Text('Customer', style: Theme.of(context).textTheme.labelLarge),
          Text('${sr.customer!.fullName} · ${sr.customer!.phone}'),
          const SizedBox(height: 16),
        ],
        Text('Pickup', style: Theme.of(context).textTheme.labelLarge),
        Text('${sr.pickupLocation.lat.toStringAsFixed(5)}, ${sr.pickupLocation.lng.toStringAsFixed(5)}'),
        if (sr.dropoffLocation != null) ...[
          const SizedBox(height: 16),
          Text('Drop-off', style: Theme.of(context).textTheme.labelLarge),
          Text('${sr.dropoffLocation!.lat.toStringAsFixed(5)}, ${sr.dropoffLocation!.lng.toStringAsFixed(5)}'),
        ],
        if (_error != null) ...[
          const SizedBox(height: 16),
          Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
        const SizedBox(height: 24),
        if (sr.status == ServiceStatus.pending)
          FilledButton(
            onPressed: _busy ? null : _accept,
            child: _busy
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Accept job'),
          ),
        if (_isTrackable(sr.status)) ...[
          FilledButton.icon(
            onPressed: () => context.push('/${widget.role.toLowerCase()}/tracking/${sr.id}'),
            icon: const Icon(Icons.map),
            label: const Text('Open live tracking'),
          ),
          const SizedBox(height: 8),
        ],
        Wrap(
          spacing: 8,
          children: [
            for (final target in _providerTargets)
              if (reachable.contains(target))
                FilledButton.tonal(
                  onPressed: _busy ? null : () => _advance(target),
                  child: Text(_actionLabel(target)),
                ),
          ],
        ),
        if (widget.role == 'MECHANIC' &&
            sr.serviceType == ServiceType.mechanic &&
            sr.status != ServiceStatus.pending) ...[
          const Divider(height: 40),
          _PartsSourcingSection(serviceRequestId: sr.id),
        ],
      ],
    );
  }

  String _actionLabel(ServiceStatus status) => switch (status) {
        ServiceStatus.enRoute => 'Mark en route',
        ServiceStatus.inProgress => 'Start job',
        ServiceStatus.completed => 'Mark completed',
        _ => status.name,
      };
}

/// Mechanic-only — "screen" per PLAN §7 is realized here as a section on
/// the job detail screen rather than a separate route, since it's scoped
/// entirely to one job and has nowhere else meaningful to live.
class _PartsSourcingSection extends ConsumerStatefulWidget {
  const _PartsSourcingSection({required this.serviceRequestId});
  final String serviceRequestId;

  @override
  ConsumerState<_PartsSourcingSection> createState() => _PartsSourcingSectionState();
}

class _PartsSourcingSectionState extends ConsumerState<_PartsSourcingSection> {
  SparePartSummary? _selected;
  int _quantity = 1;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Request parts', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        FutureBuilder<List<SparePartSummary>>(
          future: ref.read(autoserveApiProvider).browseSpareParts(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const LinearProgressIndicator();
            final parts = snapshot.data!;
            return DropdownButtonFormField<SparePartSummary>(
              initialValue: _selected,
              decoration: const InputDecoration(labelText: 'Spare part'),
              items: [
                for (final part in parts)
                  DropdownMenuItem(value: part, child: Text('${part.title} (${part.sku})')),
              ],
              onChanged: (v) => setState(() => _selected = v),
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('Quantity'),
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
            ),
            Text('$_quantity'),
            IconButton(icon: const Icon(Icons.add), onPressed: () => setState(() => _quantity++)),
          ],
        ),
        FilledButton(
          onPressed: _selected == null || _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Send request to customer'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await ref.read(autoserveApiProvider).createPartsRequest(
            serviceRequestId: widget.serviceRequestId,
            sparePartId: _selected!.id,
            quantity: _quantity,
          );
      if (!mounted) return;
      setState(() {
        _selected = null;
        _quantity = 1;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sent — waiting for the customer to approve.')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
