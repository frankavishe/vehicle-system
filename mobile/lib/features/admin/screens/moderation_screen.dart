import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/autoserve_api.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/admin_user_summary_dto.dart';
import '../../../shared/widgets/app_badge.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../widgets/confirm_action_dialog.dart';

/// spec.md FR-005 — locate a user/provider account by name or email and
/// take a moderation action. ADMIN-role accounts are excluded from
/// results (server also rejects them with 403 — this is a UX nicety on
/// top of a real guard, not the guard itself).
class ModerationScreen extends ConsumerStatefulWidget {
  const ModerationScreen({super.key});

  @override
  ConsumerState<ModerationScreen> createState() => _ModerationScreenState();
}

class _ModerationScreenState extends ConsumerState<ModerationScreen> {
  final _controller = TextEditingController();
  List<AdminUserSummaryDto>? _results;
  bool _searching = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    setState(() {
      _searching = true;
      _error = null;
    });
    try {
      final results = await ref.read(autoserveApiProvider).searchUsers(search: query);
      if (!mounted) return;
      setState(() {
        _results = results.where((u) => u.role != 'ADMIN').toList();
      });
    } on DioException {
      if (!mounted) return;
      setState(() => _error = 'Could not search — try again.');
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Search by name or email',
                  controller: _controller,
                  onSubmitted: _search,
                ),
              ),
              const SizedBox(width: 8),
              AppButton(label: 'Search', onPressed: _searching ? null : () => _search(_controller.text)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: const Icon(Icons.payments_outlined),
              label: const Text('Trigger a manual payout'),
              onPressed: () => context.push('/admin/moderation/payout'),
            ),
          ),
        ),
        const Divider(height: 24),
        if (_searching) const Center(child: CircularProgressIndicator()),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        if (_results != null)
          Expanded(
            child: _results!.isEmpty
                ? const Center(child: Text('No matching accounts.'))
                : ListView.separated(
                    itemCount: _results!.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final u = _results![i];
                      return ListTile(
                        title: Text(u.fullName),
                        subtitle: Text('${u.email} · ${u.role}'),
                        trailing: AppBadge(
                          label: u.isActive ? 'Active' : 'Suspended',
                          tone: u.isActive ? AppTone.go : AppTone.stop,
                        ),
                        onTap: () => context.push('/admin/moderation/accounts/${u.id}'),
                      );
                    },
                  ),
          ),
      ],
    );
  }
}

class AccountDetailScreen extends ConsumerStatefulWidget {
  const AccountDetailScreen({super.key, required this.accountId});
  final String accountId;

  @override
  ConsumerState<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends ConsumerState<AccountDetailScreen> {
  AdminUserSummaryDto? _account;
  bool _loading = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      // No GET /admin/users/{id} exists — reuse the same search endpoint,
      // scoped by nothing (small account base at this launch scale, per
      // spec.md Assumptions), and pick out the one id.
      final all = await ref.read(autoserveApiProvider).searchUsers();
      if (!mounted) return;
      AdminUserSummaryDto? match;
      for (final u in all) {
        if (u.id == widget.accountId) {
          match = u;
          break;
        }
      }
      setState(() => _account = match);
    } on DioException {
      if (mounted) setState(() => _account = null);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleStatus() async {
    final account = _account;
    if (account == null) return;
    final suspending = account.isActive;

    final confirmed = await confirmAdminAction(
      context,
      title: suspending ? 'Suspend this account?' : 'Reinstate this account?',
      message: suspending
          ? '${account.fullName} will no longer be able to log in.'
          : '${account.fullName} will be able to log in again.',
      confirmLabel: suspending ? 'Suspend' : 'Reinstate',
      destructive: suspending,
    );
    if (!confirmed) return;

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final updated = await ref.read(autoserveApiProvider).setUserStatus(account.id, !account.isActive);
      if (!mounted) return;
      setState(() => _account = updated);
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.response?.data is Map
            ? (e.response?.data['detail']?.toString() ?? 'Could not update this account.')
            : 'Could not update this account.';
      });
      await _load(); // reflect current server state, not stale local state (edge case)
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _account == null
          ? const Center(child: Text('Account not found.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(_account!.fullName, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(_account!.email),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    AppBadge(label: _account!.role, tone: AppTone.neutral),
                    AppBadge(
                      label: _account!.isActive ? 'Active' : 'Suspended',
                      tone: _account!.isActive ? AppTone.go : AppTone.stop,
                    ),
                    AppBadge(
                      label: _account!.isVerified ? 'Verified' : 'Unverified',
                      tone: _account!.isVerified ? AppTone.go : AppTone.neutral,
                    ),
                  ],
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
                const SizedBox(height: 24),
                AppButton(
                  label: _account!.isActive ? 'Suspend' : 'Reinstate',
                  variant: _account!.isActive ? AppButtonVariant.danger : AppButtonVariant.primary,
                  onPressed: _busy ? null : _toggleStatus,
                  loading: _busy,
                  expand: true,
                ),
              ],
            ),
    );
  }
}
