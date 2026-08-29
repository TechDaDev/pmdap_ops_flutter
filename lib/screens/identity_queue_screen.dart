import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pmdap_operations/core/widgets.dart';
import 'package:pmdap_operations/providers.dart';

class IdentityQueueScreen extends ConsumerWidget {
  const IdentityQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(identityQueueProvider);
    return Scaffold(
      key: const Key('identity_queue_screen'),
      appBar: AppBar(title: Text(context.l10n.identityVerification)),
      body: queue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            ErrorPane(onRetry: () => ref.invalidate(identityQueueProvider)),
        data: (page) => RefreshIndicator(
          onRefresh: () => ref.refresh(identityQueueProvider.future),
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
                    return Card(
                      child: ListTile(
                        key: Key('identity_${item.id}'),
                        minVerticalPadding: 14,
                        title: Text(item.safeName),
                        subtitle: Text(
                          '${item.documentType.replaceAll('_', ' ')}\n'
                          '${item.createdAt == null ? '' : DateFormat.yMMMd().add_Hm().format(item.createdAt!.toLocal())}',
                        ),
                        isThreeLine: true,
                        trailing: item.corrected
                            ? StatusPill(
                                label: context.l10n.corrected,
                                positive: true,
                              )
                            : const Icon(Icons.chevron_right),
                        onTap: () => context.push('/identities/${item.id}'),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
