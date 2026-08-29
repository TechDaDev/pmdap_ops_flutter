import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pmdap_operations/app.dart';
import 'package:pmdap_operations/providers.dart';

import '../test/helpers/fakes.dart';

const reviewerEmail = 'm30-reviewer@example.test';
const reviewerPassword = 'M30-Synthetic-Only!';
const patientEmail = 'm30-patient@example.test';
const patientPassword = 'M30-Patient-Synthetic!';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('real backend denies patient access', (tester) async {
    await _pumpApp(tester);
    await _login(tester, patientEmail, patientPassword);
    expect(find.byKey(const Key('login_error')), findsOneWidget);
    expect(find.byKey(const Key('identity_queue_card')), findsNothing);
  });

  testWidgets('reviewer completes real-backend M30 operations flows', (
    tester,
  ) async {
    await _pumpApp(tester);
    await _login(tester, reviewerEmail, reviewerPassword);
    expect(find.byKey(const Key('identity_queue_card')), findsOneWidget);

    await tester.tap(find.byKey(const Key('identity_queue_card')));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('SyntheticApprove'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('view_front')));
    await _pumpUntilFound(tester, find.byKey(const Key('private_image_front')));
    expect(find.byKey(const Key('private_image_front')), findsOneWidget);
    await tester.tap(find.byKey(const Key('image_side_back')));
    await _pumpUntilFound(tester, find.byKey(const Key('private_image_back')));
    expect(find.byKey(const Key('private_image_back')), findsOneWidget);
    await _goBack(tester);

    await tester.enterText(
      find.byKey(const Key('field_given_name')),
      'SyntheticCorrected',
    );
    await _scrollTap(tester, const Key('save_corrections'));
    await tester.pump(const Duration(seconds: 2));
    await tester.fling(
      find.byType(Scrollable).first,
      const Offset(0, 2000),
      2000,
    );
    await tester.pumpAndSettle();
    await _pumpUntilFound(tester, find.text('Corrected'));
    expect(find.text('Corrected'), findsWidgets);

    await _scrollTap(tester, const Key('approve_identity'));
    await tester.tap(find.byKey(const Key('confirm_action')));
    await _pumpUntilAbsent(tester, find.byKey(const Key('approve_identity')));
    await _pumpUntilFound(
      tester,
      find.byKey(const Key('identity_queue_screen')),
    );
    await _pumpUntilFound(tester, find.textContaining('SyntheticReject'));
    expect(find.textContaining('SyntheticApprove'), findsNothing);

    await tester.tap(find.textContaining('SyntheticReject'));
    await tester.pumpAndSettle();
    await _scrollTap(tester, const Key('reject_identity'));
    await tester.enterText(
      find.byKey(const Key('rejection_reason')),
      'Synthetic E2E rejection reason',
    );
    await tester.tap(find.byKey(const Key('confirm_rejection')));
    await _pumpUntilAbsent(tester, find.byKey(const Key('reject_identity')));
    await _pumpUntilFound(
      tester,
      find.byKey(const Key('identity_queue_screen')),
    );
    await _pumpUntilAbsent(tester, find.textContaining('SyntheticReject'));
    expect(find.textContaining('SyntheticReject'), findsNothing);

    await _goBack(tester);
    await tester.tap(find.byKey(const Key('guardian_queue_card')));
    await _pumpUntilFound(tester, find.textContaining('Layla Approve'));

    await tester.tap(find.textContaining('Layla Approve'));
    await _pumpUntilFound(tester, find.text('Adult identity'));
    final approveGuardian = find.byKey(const Key('approve_guardian'));
    await _scrollIntoView(tester, const Key('approve_guardian'));
    expect(tester.widget<FilledButton>(approveGuardian).onPressed, isNotNull);
    await tester.tap(approveGuardian);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm_action')));
    await _pumpUntilAbsent(tester, find.byKey(const Key('approve_guardian')));
    await _pumpUntilFound(
      tester,
      find.byKey(const Key('guardian_queue_screen')),
    );
    await _pumpUntilFound(tester, find.textContaining('Layla Ineligible'));
    expect(find.textContaining('Layla Approve'), findsNothing);

    await tester.tap(find.textContaining('Layla Ineligible'));
    await _pumpUntilFound(tester, find.text('Adult identity'));
    final disabledApprove = find.byKey(const Key('approve_guardian'));
    await _scrollIntoView(tester, const Key('approve_guardian'));
    expect(tester.widget<FilledButton>(disabledApprove).onPressed, isNull);
    await _goBack(tester);
    await _pumpUntilFound(tester, find.textContaining('Layla Reject'));

    await tester.tap(find.textContaining('Layla Reject'));
    await _pumpUntilFound(tester, find.text('Adult identity'));
    await _scrollTap(tester, const Key('reject_guardian'));
    await tester.enterText(
      find.byKey(const Key('rejection_reason')),
      'Synthetic guardian rejection reason',
    );
    await tester.tap(find.byKey(const Key('confirm_rejection')));
    await _pumpUntilAbsent(tester, find.byKey(const Key('reject_guardian')));
    await _pumpUntilFound(
      tester,
      find.byKey(const Key('guardian_queue_screen')),
    );
    await _pumpUntilFound(tester, find.textContaining('Layla Ineligible'));
    expect(find.textContaining('Layla Reject'), findsNothing);

    await _goBack(tester);
    await tester.tap(find.byKey(const Key('logout_button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('login_submit')), findsOneWidget);
  });
}

Future<void> _pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [tokenStoreProvider.overrideWithValue(MemoryTokenStore())],
      child: const OperationsApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _login(WidgetTester tester, String email, String password) async {
  await tester.enterText(find.byKey(const Key('login_email')), email);
  await tester.enterText(find.byKey(const Key('login_password')), password);
  await tester.pumpAndSettle();
  final submit = find.byKey(const Key('login_submit'));
  await tester.ensureVisible(submit);
  await tester.tap(submit);
  await tester.pumpAndSettle();
}

Future<void> _goBack(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}

Future<void> _scrollTap(WidgetTester tester, Key key) async {
  await _scrollIntoView(tester, key);
  await tester.tap(find.byKey(key));
  await tester.pumpAndSettle();
}

Future<void> _scrollIntoView(WidgetTester tester, Key key) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  final target = find.byKey(key);
  final scrollable = find.byType(Scrollable).first;
  await tester.scrollUntilVisible(target, 300, scrollable: scrollable);
  await tester.drag(scrollable, const Offset(0, -160));
  await tester.pumpAndSettle();
}

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 50; attempt++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
    if (finder.evaluate().isNotEmpty) return;
  }
  expect(finder, findsWidgets);
}

Future<void> _pumpUntilAbsent(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 50; attempt++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
    if (finder.evaluate().isEmpty) return;
  }
  expect(finder, findsNothing);
}
