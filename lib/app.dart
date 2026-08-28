import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pmdap_operations/core/theme.dart';
import 'package:pmdap_operations/features/auth/session_controller.dart';
import 'package:pmdap_operations/l10n/app_localizations.dart';
import 'package:pmdap_operations/providers.dart';
import 'package:pmdap_operations/screens/guardian_detail_screen.dart';
import 'package:pmdap_operations/screens/guardian_queue_screen.dart';
import 'package:pmdap_operations/screens/home_screen.dart';
import 'package:pmdap_operations/screens/identity_detail_screen.dart';
import 'package:pmdap_operations/screens/identity_queue_screen.dart';
import 'package:pmdap_operations/screens/login_screen.dart';
import 'package:pmdap_operations/screens/private_image_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SessionGate()),
      GoRoute(
        path: '/identities',
        builder: (context, state) =>
            const SessionGate(child: IdentityQueueScreen()),
      ),
      GoRoute(
        path: '/identities/:id',
        builder: (_, state) => SessionGate(
          child: IdentityDetailScreen(id: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/identity-images/:id/:side',
        builder: (_, state) => SessionGate(
          child: PrivateImageScreen(
            documentId: state.pathParameters['id']!,
            initialSide: state.pathParameters['side']!,
          ),
        ),
      ),
      GoRoute(
        path: '/guardians',
        builder: (context, state) =>
            const SessionGate(child: GuardianQueueScreen()),
      ),
      GoRoute(
        path: '/guardians/:id',
        builder: (_, state) => SessionGate(
          child: GuardianDetailScreen(id: state.pathParameters['id']!),
        ),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

class OperationsApp extends ConsumerWidget {
  const OperationsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(displayPreferencesProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'PMDAP Operations',
      theme: OpsTheme.light(),
      darkTheme: OpsTheme.dark(),
      themeMode: preferences.themeMode,
      locale: preferences.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) => _ActivityBoundary(child: child),
    );
  }
}

class SessionGate extends ConsumerWidget {
  const SessionGate({super.key, this.child});
  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    return switch (session.phase) {
      SessionPhase.restoring => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      SessionPhase.signedOut || SessionPhase.signingIn => const LoginScreen(),
      SessionPhase.signedIn => child ?? const HomeScreen(),
    };
  }
}

class _ActivityBoundary extends ConsumerStatefulWidget {
  const _ActivityBoundary({this.child});
  final Widget? child;

  @override
  ConsumerState<_ActivityBoundary> createState() => _ActivityBoundaryState();
}

class _ActivityBoundaryState extends ConsumerState<_ActivityBoundary>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(sessionProvider.notifier).recordActivity();
    }
  }

  @override
  Widget build(BuildContext context) => Listener(
    behavior: HitTestBehavior.translucent,
    onPointerDown: (_) => ref.read(sessionProvider.notifier).recordActivity(),
    child: widget.child ?? const SizedBox.shrink(),
  );
}
