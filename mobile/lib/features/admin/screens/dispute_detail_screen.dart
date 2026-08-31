import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/autoserve_api.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/dispute_dto.dart';
import '../widgets/confirm_action_dialog.dart';

final _disputeDetailProvider = FutureProvider.autoDispose.family<DisputeDto, String>((ref, id) {
  // The list endpoint already carries full detail (no separate
  // GET /admin/disputes/{id} exists — research.md §3) — filtering the
  // list to one id keeps this screen on the same single source of truth
  // the list screen already fetched from.
  return ref.watch(autoserveApiProvider).listDisputes().then(
        (all) => all.firstWhere((d) => d.id == id, orElse: () => throw DioException(
              requestOptions: RequestOptions(path: '/admin/disputes/$id'),
              response: Response(
                requestOptions: RequestOptions(path: '/admin/disputes/$id'),
                statusCode: 404,
                data: {'detail': 'Dispute not found.'},
              ),
            )),
      );
});

class DisputeDetailScreen extends ConsumerWidget {
  const DisputeDetailScreen({super.key, required this.disputeId});
  final String disputeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(_disputeDetailProvider(disputeId));

    return Scaffold(
      appBar: AppBar(title: const Text('Dispute')),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(_disputeDetailProvider(disputeId)),
            child: const Text('Could not load this dispute — tap to retry'),
          ),
        ),
        data: (d) => _DisputeDetailBody(dispute: d),
      ),
    );
  }
}

class _DisputeDetailBody extends ConsumerStatefulWidget {
  const _DisputeDetailBody({required this.dispute});
  final DisputeDto dispute;

  @override
  ConsumerState<_DisputeDetailBody> createState() => _DisputeDetailBodyState();
}

class _DisputeDetailBodyState extends ConsumerState<_DisputeDetailBody> {
  bool _busy = false;
  String? _error;

  Future<void> _resolve() async {
    final confirmed = await confirmAdminAction(
      context,
      title: 'Resolve dispute?',
      message: "This marks the dispute resolved. It can't be resolved again afterward.",
      confirmLabel: 'Resolve',
    );
    if (!confirmed) return;

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(autoserveApiProvider).resolveDispute(widget.dispute.id);
      ref.invalidate(_disputeDetailProvider(widget.dispute.id));
    } on DioException catch (e) {
      // 400 "already resolved" (another admin got there first, edge case
      // #1) surfaces the server's own message rather than a generic
      // error — the server is the single arbiter, per spec.md FR-003.
      setState(() {
        _error = e.response?.data is Map
            ? (e.response?.data['detail']?.toString() ?? 'Could not resolve this dispute.')
            : 'Could not resolve this dispute.';
      });
      ref.invalidate(_disputeDetailProvider(widget.dispute.id));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.dispute;
    final job = d.serviceRequestSummary;
    final isOpen = d.status == DisputeStatus.open;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Text('Dispute', style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            Chip(
              label: Text(d.status.name.toUpperCase()),
              backgroundColor: statusColor(isOpen ? 'PENDING' : 'COMPLETED').withValues(alpha: 0.15),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (job != null) ...[
          Text('Job', style: Theme.of(context).textTheme.labelLarge),
          Text('${job.serviceType == 'MECHANIC' ? 'Mechanic' : 'Towing'} — ${job.status}'),
          const SizedBox(height: 16),
        ],
        Text('Raised by', style: Theme.of(context).textTheme.labelLarge),
        Text(d.raisedByName ?? 'Unknown'),
        if (d.raisedByEmail != null) Text(d.raisedByEmail!, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 16),
        Text('Reason', style: Theme.of(context).textTheme.labelLarge),
        Text(d.reason ?? 'No reason given'),
        if (!isOpen) ...[
          const SizedBox(height: 16),
          Text('Resolved by', style: Theme.of(context).textTheme.labelLarge),
          Text(d.resolvedByName ?? 'Unknown admin'),
        ],
        if (_error != null) ...[
          const SizedBox(height: 16),
          Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
        const SizedBox(height: 24),
        if (isOpen)
          FilledButton(
            onPressed: _busy ? null : _resolve,
            child: _busy
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Resolve'),
          ),
      ],
    );
  }
}
