import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pmdap_operations/core/models.dart';
import 'package:pmdap_operations/core/widgets.dart';
import 'package:pmdap_operations/providers.dart';

const _fieldOrder = [
  'given_name',
  'father_name',
  'grandfather_name',
  'mother_name',
  'date_of_birth',
  'sex',
  'blood_group',
  'nationality',
  'national_number',
  'unique_card_body_number',
  'family_number',
  'issue_date',
  'expiry_date',
];

String _fieldLabel(BuildContext context, String name) => switch (name) {
  'given_name' => context.l10n.firstName,
  'father_name' => context.l10n.fatherName,
  'grandfather_name' => context.l10n.grandfatherName,
  'mother_name' => context.l10n.motherName,
  'date_of_birth' => context.l10n.dateOfBirth,
  'sex' => context.l10n.sex,
  'blood_group' => context.l10n.bloodGroup,
  'nationality' => context.l10n.nationality,
  'national_number' => context.l10n.nationalNumber,
  'unique_card_body_number' => context.l10n.cardBodyNumber,
  'family_number' => context.l10n.familyNumber,
  'issue_date' => context.l10n.issueDate,
  'expiry_date' => context.l10n.expiryDate,
  _ => name,
};

class IdentityDetailScreen extends ConsumerStatefulWidget {
  const IdentityDetailScreen({super.key, required this.id});
  final String id;

  @override
  ConsumerState<IdentityDetailScreen> createState() =>
      _IdentityDetailScreenState();
}

class _IdentityDetailScreenState extends ConsumerState<IdentityDetailScreen> {
  final Map<String, TextEditingController> _controllers = {};
  int? _loadedVersion;
  bool _saving = false;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _sync(IdentityReviewDetail detail) {
    if (_loadedVersion == detail.reviewVersion) return;
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    for (final field in detail.fields) {
      _controllers[field.name] = TextEditingController(text: field.reviewed);
    }
    _loadedVersion = detail.reviewVersion;
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(identityDetailProvider(widget.id));
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.identityDetail)),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorPane(
          onRetry: () => ref.invalidate(identityDetailProvider(widget.id)),
        ),
        data: (value) {
          _sync(value);
          final fields = {for (final field in value.fields) field.name: field};
          final canEdit = value.availableActions.contains('review_fields');
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                value.safeName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(value.documentType.replaceAll('_', ' ')),
              if (value.hasCorrections) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: StatusPill(
                    label: context.l10n.corrected,
                    positive: true,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('view_front'),
                      onPressed: () =>
                          context.push('/identity-images/${value.id}/front'),
                      icon: const Icon(Icons.credit_card),
                      label: Text(context.l10n.front),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('view_back'),
                      onPressed: () =>
                          context.push('/identity-images/${value.id}/back'),
                      icon: const Icon(Icons.credit_card),
                      label: Text(context.l10n.back),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              for (final name in _fieldOrder)
                if (fields[name] case final field?)
                  _ReviewField(
                    field: field,
                    label: _fieldLabel(context, name),
                    controller: _controllers[name]!,
                    enabled: canEdit && !_saving,
                  ),
              if (canEdit) ...[
                const SizedBox(height: 8),
                FilledButton.icon(
                  key: const Key('save_corrections'),
                  onPressed: _saving ? null : () => _save(value),
                  icon: const Icon(Icons.save_outlined),
                  label: Text(context.l10n.saveCorrections),
                ),
              ],
              const SizedBox(height: 12),
              if (value.availableActions.contains('approve'))
                FilledButton.icon(
                  key: const Key('approve_identity'),
                  onPressed: _saving ? null : () => _approve(value),
                  icon: const Icon(Icons.verified_outlined),
                  label: Text(context.l10n.approve),
                ),
              if (value.availableActions.contains('reject')) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  key: const Key('reject_identity'),
                  onPressed: _saving ? null : () => _reject(value),
                  icon: const Icon(Icons.block_outlined),
                  label: Text(context.l10n.reject),
                ),
              ],
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Future<void> _save(IdentityReviewDetail detail) async {
    final changed = <String, String?>{};
    for (final field in detail.fields) {
      final value = _controllers[field.name]?.text.trim() ?? '';
      if (value != field.reviewed) {
        changed[field.name] = value.isEmpty ? null : value;
      }
    }
    if (changed.isEmpty) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(opsRepositoryProvider)
          .saveIdentityFields(detail.id, detail.reviewVersion, changed);
      ref.invalidate(identityDetailProvider(widget.id));
      ref.invalidate(identityQueueProvider);
    } on ApiFailure catch (error) {
      if (!mounted) return;
      final message = error.isStale
          ? context.l10n.reviewChanged
          : error.message;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      if (error.isStale) ref.invalidate(identityDetailProvider(widget.id));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _approve(IdentityReviewDetail detail) async {
    final confirmed = await confirmAction(
      context,
      title: context.l10n.approveIdentityTitle,
      message: context.l10n.approveIdentityMessage,
      confirmLabel: context.l10n.approve,
    );
    if (!confirmed) return;
    setState(() => _saving = true);
    try {
      await ref.read(opsRepositoryProvider).approveIdentity(detail.id);
      ref.invalidate(identityQueueProvider);
      if (mounted) await Navigator.of(context).maybePop();
    } on ApiFailure catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _reject(IdentityReviewDetail detail) async {
    final reason = await requestReason(
      context,
      context.l10n.rejectIdentityTitle,
    );
    if (reason == null) return;
    setState(() => _saving = true);
    try {
      await ref.read(opsRepositoryProvider).rejectIdentity(detail.id, reason);
      ref.invalidate(identityQueueProvider);
      if (mounted) await Navigator.of(context).maybePop();
    } on ApiFailure catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _ReviewField extends StatelessWidget {
  const _ReviewField({
    required this.field,
    required this.label,
    required this.controller,
    required this.enabled,
  });
  final IdentityReviewField field;
  final String label;
  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              if (field.corrected)
                StatusPill(label: context.l10n.corrected, positive: true),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${context.l10n.original}: ${field.original.isEmpty ? '—' : field.original}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          TextField(
            key: Key('field_${field.name}'),
            controller: controller,
            enabled: enabled,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(labelText: context.l10n.reviewed),
          ),
        ],
      ),
    ),
  );
}
