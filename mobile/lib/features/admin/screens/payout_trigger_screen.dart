import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/autoserve_api.dart';
import '../../../shared/models/admin_user_summary_dto.dart';
import '../../../shared/models/payout_dto.dart';
import '../widgets/confirm_action_dialog.dart';

/// spec.md FR-006 — manual/off-cycle payout for a specific provider.
/// Provider picker is `searchUsers` filtered client-side to
/// MECHANIC/RECOVERY (research.md §6) — reuses FR-005's search rather
/// than a second endpoint.
class PayoutTriggerScreen extends ConsumerStatefulWidget {
  const PayoutTriggerScreen({super.key});

  @override
  ConsumerState<PayoutTriggerScreen> createState() => _PayoutTriggerScreenState();
}

class _PayoutTriggerScreenState extends ConsumerState<PayoutTriggerScreen> {
  final _controller = TextEditingController();
  List<AdminUserSummaryDto>? _providers;
  AdminUserSummaryDto? _selected;
  List<PayoutDto>? _history;
  bool _busy = false;
  String? _message;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    setState(() => _busy = true);
    try {
      final results = await ref.read(autoserveApiProvider).searchUsers(search: query);
      if (!mounted) return;
      setState(() {
        _providers = results.where((u) => u.role == 'MECHANIC' || u.role == 'RECOVERY').toList();
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _select(AdminUserSummaryDto provider) async {
    setState(() {
      _selected = provider;
      _history = null;
      _message = null;
    });
    final history = await ref.read(autoserveApiProvider).listPayouts(provider: provider.id);
    if (!mounted) return;
    setState(() => _history = history);
  }

  Future<void> _trigger() async {
    final provider = _selected;
    if (provider == null) return;

    final confirmed = await confirmAdminAction(
      context,
      title: 'Trigger manual payout?',
      message: 'This triggers an off-cycle payout for ${provider.fullName} covering their completed, '
          'unpaid jobs.',
      confirmLabel: 'Trigger payout',
    );
    if (!confirmed) return;

    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await ref.read(autoserveApiProvider).triggerManualPayout(provider.id);
      if (!mounted) return;
      setState(() => _message = 'Payout triggered.');
      await _select(provider);
    } on DioException catch (e) {
      // 404 = nothing outstanding to pay out — already enforced
      // server-side (AdminPayoutTriggerView); surfaced plainly rather
      // than as a generic failure (spec.md's zero/invalid-payout edge
      // case).
      if (!mounted) return;
      setState(() {
        _message = e.response?.statusCode == 404
            ? (e.response?.data is Map
                ? (e.response?.data['detail']?.toString() ?? 'Nothing outstanding to pay out.')
                : 'Nothing outstanding to pay out.')
            : 'Could not trigger this payout.';
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manual payout')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'Search provider by name or email',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: _search,
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _busy ? null : () => _search(_controller.text),
                child: const Text('Search'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_providers != null)
            for (final p in _providers!)
              ListTile(
                leading: Icon(
                  _selected?.id == p.id ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                ),
                title: Text(p.fullName),
                subtitle: Text('${p.email} · ${p.role}'),
                onTap: () => _select(p),
              ),
          if (_selected != null) ...[
            const Divider(height: 32),
            Text('Payout history', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (_history == null)
              const Center(child: CircularProgressIndicator())
            else if (_history!.isEmpty)
              const Text('No payouts on file for this provider.')
            else
              for (final payout in _history!)
                ListTile(
                  title: Text('${payout.amount} — ${payout.status.name}'),
                  subtitle: Text(payout.isManual ? 'Manual' : 'Scheduled'),
                ),
            const SizedBox(height: 16),
            if (_message != null) Text(_message!),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _busy ? null : _trigger,
              child: _busy
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Trigger manual payout'),
            ),
          ],
        ],
      ),
    );
  }
}
