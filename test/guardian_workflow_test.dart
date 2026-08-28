import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pmdap_operations/providers.dart';
import 'package:pmdap_operations/screens/guardian_detail_screen.dart';

import 'helpers/fakes.dart';
import 'helpers/pump.dart';

void main() {
  testWidgets(
    'father evidence renders backend family and father-name results',
    (tester) async {
      final repository = FakeOpsRepository();
      await pumpOps(
        tester,
        const GuardianDetailScreen(id: 'guardian-1'),
        overrides: [opsRepositoryProvider.overrideWithValue(repository)],
      );

      expect(find.text('FATHER'), findsOneWidget);
      await reveal(tester, find.textContaining('Verified cards match'));
      expect(find.textContaining('Verified cards match'), findsOneWidget);
      expect(find.textContaining('Verified names match'), findsOneWidget);
      await reveal(tester, find.text('Ready for review'));
      expect(find.text('Ready for review'), findsOneWidget);
    },
  );

  testWidgets('mother evidence renders maternal backend result', (
    tester,
  ) async {
    final repository = FakeOpsRepository()
      ..guardianValue = guardianDetail(
        relationship: 'MOTHER',
        nameKind: 'MOTHER',
      );
    await pumpOps(
      tester,
      const GuardianDetailScreen(id: 'guardian-1'),
      overrides: [opsRepositoryProvider.overrideWithValue(repository)],
    );

    expect(find.text('MOTHER'), findsOneWidget);
    await reveal(tester, find.textContaining('Verified names match'));
    expect(find.textContaining('Verified names match'), findsOneWidget);
  });

  testWidgets('legal guardian renders official evidence only', (tester) async {
    final repository = FakeOpsRepository()
      ..guardianValue = guardianDetail(
        relationship: 'LEGAL_GUARDIAN',
        official: true,
      );
    await pumpOps(
      tester,
      const GuardianDetailScreen(id: 'guardian-1'),
      overrides: [opsRepositoryProvider.overrideWithValue(repository)],
    );

    expect(find.text('LEGAL GUARDIAN'), findsOneWidget);
    await reveal(tester, find.text('Official guardianship evidence'));
    expect(find.text('Official guardianship evidence'), findsOneWidget);
  });

  testWidgets('approve disabled when backend says ineligible', (tester) async {
    final repository = FakeOpsRepository()
      ..guardianValue = guardianDetail(eligible: false);
    await pumpOps(
      tester,
      const GuardianDetailScreen(id: 'guardian-1'),
      overrides: [opsRepositoryProvider.overrideWithValue(repository)],
    );
    final approve = find.byKey(const Key('approve_guardian'));
    await reveal(tester, approve);
    final button = tester.widget<FilledButton>(approve);

    expect(button.onPressed, isNull);
    expect(find.text('Evidence incomplete'), findsOneWidget);
    expect(find.textContaining('Verified cards do not match'), findsOneWidget);
  });

  testWidgets('guardian approve confirms then calls backend', (tester) async {
    final repository = FakeOpsRepository();
    await pumpOps(
      tester,
      const GuardianDetailScreen(id: 'guardian-1'),
      overrides: [opsRepositoryProvider.overrideWithValue(repository)],
    );
    final approve = find.byKey(const Key('approve_guardian'));
    await reveal(tester, approve);
    await tester.tap(approve);
    await tester.pumpAndSettle();
    expect(repository.approvedGuardianId, isNull);
    await tester.tap(find.widgetWithText(FilledButton, 'Approve').last);
    await tester.pumpAndSettle();

    expect(repository.approvedGuardianId, 'guardian-1');
  });

  testWidgets('guardian reject requires reason', (tester) async {
    final repository = FakeOpsRepository();
    await pumpOps(
      tester,
      const GuardianDetailScreen(id: 'guardian-1'),
      overrides: [opsRepositoryProvider.overrideWithValue(repository)],
    );
    final reject = find.byKey(const Key('reject_guardian'));
    await reveal(tester, reject);
    await tester.tap(reject);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField).last,
      'Synthetic evidence issue',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Reject'));
    await tester.pumpAndSettle();

    expect(repository.rejectedGuardianReason, 'Synthetic evidence issue');
  });
}
