import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pmdap_operations/app.dart';
import 'package:pmdap_operations/providers.dart';

import '../test/helpers/fakes.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('synthetic reviewer completes identity review flow', (
    tester,
  ) async {
    final repository = FakeOpsRepository();
    final tokens = MemoryTokenStore();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          opsRepositoryProvider.overrideWithValue(repository),
          tokenStoreProvider.overrideWithValue(tokens),
        ],
        child: const OperationsApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('login_email')),
      'reviewer@example.test',
    );
    await tester.enterText(
      find.byKey(const Key('login_password')),
      'synthetic-password',
    );
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('identity_queue_card')), findsOneWidget);
    await tester.tap(find.byKey(const Key('identity_queue_card')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('identity_identity-1')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('field_given_name')),
      'Synthetic',
    );
    final save = find.byKey(const Key('save_corrections'));
    await tester.scrollUntilVisible(
      save,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(repository.savedVersion, 2);
    expect(repository.savedFields, {'given_name': 'Synthetic'});
  });
}
