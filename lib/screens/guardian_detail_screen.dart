import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pmdap_operations/core/models.dart';
import 'package:pmdap_operations/core/widgets.dart';
import 'package:pmdap_operations/providers.dart';

class GuardianDetailScreen extends ConsumerStatefulWidget {
  const GuardianDetailScreen({super.key, required this.id});
  final String id;

  @override
  ConsumerState<GuardianDetailScreen> createState() =>
      _GuardianDetailScreenState();
}

class _GuardianDetailScreenState extends ConsumerState<GuardianDetailScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(guardianDetailProvider(widget.id));
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.guardianDetail)),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorPane(
          onRetry: () => ref.invalidate(guardianDetailProvider(widget.id)),
        ),
        data: (value) {
          final item = value.item;
          final evidence = value.evaluation;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                item.relationship.replaceAll('_', ' '),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              _PersonCard(
                title: context.l10n.adultIdentity,
                name: item.adultName,
                verified: evidence.adultIdentityVerified,
                documentId: evidence.adultDocumentId,
              ),
              const SizedBox(height: 10),
              _PersonCard(
                title: context.l10n.minorIdentity,
                name: item.minorName,
                verified: evidence.minorIdentityVerified,
                documentId: evidence.minorDocumentId,
              ),
              const SizedBox(height: 18),
              Text(
                context.l10n.relationshipEvidence,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              _EvidenceRow(
                label: context.l10n.adultIdentityVerified,
                passed: evidence.adultIdentityVerified,
              ),
              _EvidenceRow(
                label: context.l10n.minorIdentityVerified,
                passed: evidence.minorIdentityVerified,
              ),
              _EvidenceRow(
                label: context.l10n.ageEligible,
                passed: evidence.ageValid,
              ),
              if (item.relationship != 'LEGAL_GUARDIAN') ...[
                _EvidenceRow(
                  label: context.l10n.familyEvidence(
                    evidence.familyResult == 'MATCH'
                        ? context.l10n.familyMatch
                        : context.l10n.familyMismatch,
                  ),
                  passed: evidence.familyResult == 'MATCH',
                ),
                _EvidenceRow(
                  label: evidence.nameResult == 'MATCH'
                      ? context.l10n.nameMatch
                      : context.l10n.nameMismatch,
                  passed: evidence.nameResult == 'MATCH',
                ),
              ] else
                _EvidenceRow(
                  label: context.l10n.officialEvidence,
                  passed: evidence.officialEvidencePresent,
                ),
              const SizedBox(height: 12),
              StatusPill(
                label: evidence.eligible
                    ? context.l10n.readyForReview
                    : context.l10n.evidenceIncomplete,
                positive: evidence.eligible,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                key: const Key('approve_guardian'),
                onPressed: evidence.eligible && !_busy
                    ? () => _approve(value)
                    : null,
                icon: const Icon(Icons.verified_outlined),
                label: Text(context.l10n.approve),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                key: const Key('reject_guardian'),
                onPressed: _busy ? null : () => _reject(value),
                icon: const Icon(Icons.block_outlined),
                label: Text(context.l10n.reject),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Future<void> _approve(GuardianReviewDetail detail) async {
    final confirmed = await confirmAction(
      context,
      title: context.l10n.approveGuardianTitle,
      message: context.l10n.approveGuardianMessage,
      confirmLabel: context.l10n.approve,
    );
    if (!confirmed) return;
    setState(() => _busy = true);
    try {
      await ref.read(opsRepositoryProvider).approveGuardian(detail.item.id);
      ref.invalidate(guardianQueueProvider);
      if (mounted) await Navigator.of(context).maybePop();
    } on ApiFailure catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
        ref.invalidate(guardianDetailProvider(widget.id));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reject(GuardianReviewDetail detail) async {
    final reason = await requestReason(
      context,
      context.l10n.rejectGuardianTitle,
    );
    if (reason == null) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(opsRepositoryProvider)
          .rejectGuardian(detail.item.id, reason);
      ref.invalidate(guardianQueueProvider);
      if (mounted) await Navigator.of(context).maybePop();
    } on ApiFailure catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _PersonCard extends StatelessWidget {
  const _PersonCard({
    required this.title,
    required this.name,
    required this.verified,
    required this.documentId,
  });
  final String title;
  final String name;
  final bool verified;
  final String? documentId;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(name),
          const SizedBox(height: 8),
          StatusPill(
            label: verified ? context.l10n.verified : context.l10n.notVerified,
            positive: verified,
          ),
          if (documentId != null) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () =>
                  context.push('/identity-images/$documentId/front'),
              icon: const Icon(Icons.credit_card),
              label: Text(context.l10n.viewCard),
            ),
          ],
        ],
      ),
    ),
  );
}

class _EvidenceRow extends StatelessWidget {
  const _EvidenceRow({required this.label, required this.passed});
  final String label;
  final bool passed;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$label: ${passed ? context.l10n.pass : context.l10n.notSatisfied}',
    child: ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        passed ? Icons.check_circle : Icons.cancel_outlined,
        color: passed
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.error,
      ),
      title: Text(label),
      trailing: Text(
        passed ? context.l10n.pass : context.l10n.blocked,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
  );
}
