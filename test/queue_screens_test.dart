import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pmdap_operations/core/models.dart';
import 'package:pmdap_operations/providers.dart';
import 'package:pmdap_operations/screens/guardian_queue_screen.dart';
import 'package:pmdap_operations/screens/identity_queue_screen.dart';

import 'helpers/fakes.dart';
import 'helpers/pump.dart';

void main() {
  testWidgets('identity queue renders safe summary data only', (tester) async {
    final repository = FakeOpsRepository();
    await pumpOps(
      tester,
      const IdentityQueueScreen(),
      overrides: [opsRepositoryProvider.overrideWithValue(repository)],
    );

    expect(find.text('Synthetic Reviewer Subject'), findsOneWidget);
    expect(find.textContaining('UNIFIED NATIONAL CARD'), findsOneWidget);
    expect(find.textContaining('National number'), findsNothing);
    expect(find.textContaining('Family number'), findsNothing);
  });

  testWidgets('identity queue supports empty state', (tester) async {
    final repository = FakeOpsRepository()
      ..identityPage = const Paged(count: 0, items: []);
    await pumpOps(
      tester,
      const IdentityQueueScreen(),
      overrides: [opsRepositoryProvider.overrideWithValue(repository)],
    );

    expect(find.text('No requests awaiting review'), findsOneWidget);
  });

  testWidgets('identity queue supports error and retry state', (tester) async {
    final repository = FakeOpsRepository()
      ..identityQueueError = const ApiFailure(
        code: 'network_error',
        message: 'Synthetic failure',
      );
    await pumpOps(
      tester,
      const IdentityQueueScreen(),
      overrides: [opsRepositoryProvider.overrideWithValue(repository)],
    );

    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets(
    'guardian queue renders backend readiness without raw identifiers',
    (tester) async {
      final repository = FakeOpsRepository();
      await pumpOps(
        tester,
        const GuardianQueueScreen(),
        overrides: [opsRepositoryProvider.overrideWithValue(repository)],
      );

      expect(find.text('Ready for review'), findsOneWidget);
      expect(find.textContaining('Synthetic Adult'), findsOneWidget);
      expect(find.textContaining('FAM-'), findsNothing);
      expect(find.textContaining('National number'), findsNothing);
    },
  );

  testWidgets('guardian queue marks incomplete evidence with text and icon', (
    tester,
  ) async {
    final repository = FakeOpsRepository();
    final incomplete = guardianDetail(eligible: false).item;
    repository.guardianPage = Paged(count: 1, items: [incomplete]);
    await pumpOps(
      tester,
      const GuardianQueueScreen(),
      overrides: [opsRepositoryProvider.overrideWithValue(repository)],
    );

    expect(find.text('Evidence incomplete'), findsOneWidget);
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
  });

  testWidgets('Arabic layout is RTL on small phone', (tester) async {
    final repository = FakeOpsRepository();
    await pumpOps(
      tester,
      const GuardianQueueScreen(),
      locale: const Locale('ar'),
      size: const Size(320, 568),
      overrides: [opsRepositoryProvider.overrideWithValue(repository)],
    );

    expect(
      Directionality.of(tester.element(find.byType(Scaffold))),
      TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('queue supports dark theme', (tester) async {
    final repository = FakeOpsRepository();
    await pumpOps(
      tester,
      const IdentityQueueScreen(),
      themeMode: ThemeMode.dark,
      overrides: [opsRepositoryProvider.overrideWithValue(repository)],
    );

    final context = tester.element(find.byType(Scaffold));
    expect(Theme.of(context).brightness, Brightness.dark);
  });
}
