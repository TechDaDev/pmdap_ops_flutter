import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pmdap_operations/core/models.dart';
import 'package:pmdap_operations/providers.dart';
import 'package:pmdap_operations/screens/identity_detail_screen.dart';
import 'package:pmdap_operations/screens/private_image_screen.dart';

import 'helpers/fakes.dart';
import 'helpers/pump.dart';

void main() {
  testWidgets('identity detail shows typed fields and original values', (
    tester,
  ) async {
    final repository = FakeOpsRepository();
    await pumpOps(
      tester,
      const IdentityDetailScreen(id: 'identity-1'),
      overrides: [opsRepositoryProvider.overrideWithValue(repository)],
    );

    expect(find.text('First name'), findsOneWidget);
    expect(find.textContaining('OCR/original: Synthetc'), findsOneWidget);
    expect(find.byKey(const Key('view_front')), findsOneWidget);
    expect(find.byKey(const Key('view_back')), findsOneWidget);
  });

  testWidgets('correction sends changed fields and review version only', (
    tester,
  ) async {
    final repository = FakeOpsRepository();
    await pumpOps(
      tester,
      const IdentityDetailScreen(id: 'identity-1'),
      overrides: [opsRepositoryProvider.overrideWithValue(repository)],
    );
    await tester.enterText(
      find.byKey(const Key('field_given_name')),
      'Synthetic',
    );
    final save = find.byKey(const Key('save_corrections'));
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(repository.savedVersion, 2);
    expect(repository.savedFields, {'given_name': 'Synthetic'});
  });

  testWidgets('409 stale review reloads and explains conflict', (tester) async {
    final repository = FakeOpsRepository()
      ..saveError = const ApiFailure(
        code: 'identity_transition_conflict',
        message: 'Stale review.',
        statusCode: 409,
      );
    await pumpOps(
      tester,
      const IdentityDetailScreen(id: 'identity-1'),
      overrides: [opsRepositoryProvider.overrideWithValue(repository)],
    );
    await tester.enterText(
      find.byKey(const Key('field_given_name')),
      'Synthetic',
    );
    final save = find.byKey(const Key('save_corrections'));
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pump();

    expect(
      find.text('Review changed on server. Reloaded latest values.'),
      findsOneWidget,
    );
  });

  testWidgets('validation error stays on detail screen', (tester) async {
    final repository = FakeOpsRepository()
      ..saveError = const ApiFailure(
        code: 'validation_error',
        message: 'Issue date must be valid.',
        statusCode: 400,
        details: {
          'issue_date': ['Issue date must be valid.'],
        },
      );
    await pumpOps(
      tester,
      const IdentityDetailScreen(id: 'identity-1'),
      overrides: [opsRepositoryProvider.overrideWithValue(repository)],
    );
    await tester.enterText(
      find.byKey(const Key('field_issue_date')),
      'invalid',
    );
    final save = find.byKey(const Key('save_corrections'));
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pump();

    expect(find.text('Issue date must be valid.'), findsOneWidget);
  });

  testWidgets('approve requires explicit confirmation', (tester) async {
    final repository = FakeOpsRepository();
    await pumpOps(
      tester,
      const IdentityDetailScreen(id: 'identity-1'),
      overrides: [opsRepositoryProvider.overrideWithValue(repository)],
    );
    final approve = find.byKey(const Key('approve_identity'));
    await reveal(tester, approve);
    await tester.tap(approve);
    await tester.pumpAndSettle();

    expect(repository.approvedIdentityId, isNull);
    expect(find.text('Approve identity?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Approve').last);
    await tester.pumpAndSettle();

    expect(repository.approvedIdentityId, 'identity-1');
  });

  testWidgets('reject requires reason and sends it', (tester) async {
    final repository = FakeOpsRepository();
    await pumpOps(
      tester,
      const IdentityDetailScreen(id: 'identity-1'),
      overrides: [opsRepositoryProvider.overrideWithValue(repository)],
    );
    final reject = find.byKey(const Key('reject_identity'));
    await reveal(tester, reject);
    await tester.tap(reject);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Synthetic mismatch');
    await tester.tap(find.widgetWithText(FilledButton, 'Reject'));
    await tester.pumpAndSettle();

    expect(repository.rejectedIdentityReason, 'Synthetic mismatch');
  });

  testWidgets('private viewer fetches authenticated bytes and switches sides', (
    tester,
  ) async {
    final repository = FakeOpsRepository();
    await pumpOps(
      tester,
      const PrivateImageScreen(documentId: 'identity-1', initialSide: 'front'),
      overrides: [opsRepositoryProvider.overrideWithValue(repository)],
    );

    expect(repository.requestedImageSide, 'front');
    expect(find.byType(InteractiveViewer), findsOneWidget);
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(repository.requestedImageSide, 'back');
  });
}
