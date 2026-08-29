import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pmdap_operations/core/widgets.dart';
import 'package:pmdap_operations/providers.dart';

class GuardianQueueScreen extends ConsumerWidget {
  const GuardianQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(guardianQueueProvider);
    return Scaffold(
      key: const Key('guardian_queue_screen'),
      appBar: AppBar(title: Text(context.l10n.guardianRelationships)),
      body: queue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            ErrorPane(onRetry: () => ref.invalidate(guardianQueueProvider)),
        data: (page) => RefreshIndicator(
          onRefresh: () => ref.refresh(guardianQueueProvider.future),
          child: page.items.isEmpty
              ? ListView(
                  children: [
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * .65,
                      child: Center(child: Text(context.l10n.noRequests)),
                    ),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: page.items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = page.items[index];
                    final ready = item.reviewReadiness == 'READY_FOR_REVIEW';
                    return Card(
                      child: ListTile(
                        key: Key('guardian_${item.id}'),
                        minVerticalPadding: 14,
                        title: Text('${item.adultName} • ${item.minorName}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.relationship.replaceAll('_', ' ')),
                            if (item.createdAt != null)
                              Text(
                                DateFormat.yMMMd().add_Hm().format(
                                  item.createdAt!.toLocal(),
                                ),
                              ),
                            const SizedBox(height: 8),
                            StatusPill(
                              label: ready
                                  ? context.l10n.readyForReview
                                  : context.l10n.evidenceIncomplete,
                              positive: ready,
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/guardians/${item.id}'),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
