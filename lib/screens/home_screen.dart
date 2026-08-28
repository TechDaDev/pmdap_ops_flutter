import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pmdap_operations/core/widgets.dart';
import 'package:pmdap_operations/providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final identities = ref.watch(identityQueueProvider);
    final guardians = ref.watch(guardianQueueProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.appTitle),
        actions: [
          PopupMenuButton<String>(
            tooltip: context.l10n.displaySettings,
            onSelected: (value) {
              final preferences = ref.read(displayPreferencesProvider.notifier);
              switch (value) {
                case 'en':
                  preferences.setLocale(const Locale('en'));
                case 'ar':
                  preferences.setLocale(const Locale('ar'));
                case 'light':
                  preferences.setTheme(ThemeMode.light);
                case 'dark':
                  preferences.setTheme(ThemeMode.dark);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'en', child: Text(context.l10n.english)),
              PopupMenuItem(value: 'ar', child: Text(context.l10n.arabic)),
              PopupMenuItem(
                value: 'light',
                child: Text(context.l10n.lightTheme),
              ),
              PopupMenuItem(value: 'dark', child: Text(context.l10n.darkTheme)),
            ],
          ),
          IconButton(
            key: const Key('logout_button'),
            tooltip: context.l10n.logout,
            onPressed: () => ref.read(sessionProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(identityQueueProvider);
          ref.invalidate(guardianQueueProvider);
          await Future.wait([
            ref.read(identityQueueProvider.future),
            ref.read(guardianQueueProvider.future),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              context.l10n.reviewQueues,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            _QueueCard(
              key: const Key('identity_queue_card'),
              icon: Icons.badge_outlined,
              title: context.l10n.identityVerification,
              count: identities.valueOrNull?.count,
              loading: identities.isLoading,
              onTap: () => context.push('/identities'),
            ),
            const SizedBox(height: 12),
            _QueueCard(
              key: const Key('guardian_queue_card'),
              icon: Icons.family_restroom_outlined,
              title: context.l10n.guardianRelationships,
              count: guardians.valueOrNull?.count,
              loading: guardians.isLoading,
              onTap: () => context.push('/guardians'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QueueCard extends StatelessWidget {
  const _QueueCard({
    super.key,
    required this.icon,
    required this.title,
    required this.count,
    required this.loading,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final int? count;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 96),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(icon, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      loading ? '…' : '${count ?? 0} ${context.l10n.pending}',
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    ),
  );
}
