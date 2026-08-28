import 'package:flutter_test/flutter_test.dart';
import 'package:pmdap_operations/core/models.dart';
import 'package:pmdap_operations/features/auth/session_controller.dart';

import 'helpers/fakes.dart';

void main() {
  test(
    'verification agent login allowed and tokens use secure store boundary',
    () async {
      final repository = FakeOpsRepository();
      final store = MemoryTokenStore();
      final controller = SessionController(
        repository: repository,
        tokenStore: store,
      );
      await Future<void>.delayed(Duration.zero);

      await controller.login('reviewer@example.test', 'synthetic-password');

      expect(controller.state.phase, SessionPhase.signedIn);
      expect(controller.state.user?.role, 'IDENTITY_VERIFICATION_AGENT');
      expect(store.access, 'access-token');
      expect(store.refresh, 'refresh-token');
      controller.dispose();
    },
  );

  test(
    'superuser capability login allowed independent of role label',
    () async {
      final repository = FakeOpsRepository()
        ..user = const OpsUser(
          id: 'root-1',
          email: 'root@example.test',
          role: 'ADMIN',
          canVerifyIdentity: true,
        );
      final controller = SessionController(
        repository: repository,
        tokenStore: MemoryTokenStore(),
      );
      await Future<void>.delayed(Duration.zero);

      await controller.login('root@example.test', 'synthetic-password');

      expect(controller.state.phase, SessionPhase.signedIn);
      controller.dispose();
    },
  );

  test(
    'patient and ordinary staff capability denied and tokens cleared',
    () async {
      for (final role in ['PATIENT', 'ADMIN']) {
        final repository = FakeOpsRepository()
          ..user = OpsUser(
            id: 'denied-$role',
            email: 'denied@example.test',
            role: role,
            canVerifyIdentity: false,
          );
        final store = MemoryTokenStore();
        final controller = SessionController(
          repository: repository,
          tokenStore: store,
        );
        await Future<void>.delayed(Duration.zero);

        await controller.login('denied@example.test', 'synthetic-password');

        expect(controller.state.phase, SessionPhase.signedOut);
        expect(controller.state.error, 'unsupported_role');
        expect(store.access, isNull);
        expect(repository.logoutCalls, 1);
        controller.dispose();
      }
    },
  );

  test('logout revokes refresh and clears all credentials', () async {
    final repository = FakeOpsRepository();
    final store = MemoryTokenStore();
    final controller = SessionController(
      repository: repository,
      tokenStore: store,
    );
    await Future<void>.delayed(Duration.zero);
    await controller.login('reviewer@example.test', 'synthetic-password');

    await controller.logout();

    expect(controller.state.phase, SessionPhase.signedOut);
    expect(store.access, isNull);
    expect(store.refresh, isNull);
    expect(repository.logoutCalls, 1);
    controller.dispose();
  });

  test('inactivity timeout clears session', () async {
    final repository = FakeOpsRepository();
    final store = MemoryTokenStore();
    final controller = SessionController(
      repository: repository,
      tokenStore: store,
      timeout: const Duration(milliseconds: 10),
    );
    await Future<void>.delayed(Duration.zero);
    await controller.login('reviewer@example.test', 'synthetic-password');

    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(controller.state.phase, SessionPhase.signedOut);
    expect(controller.state.expired, isTrue);
    expect(store.access, isNull);
    controller.dispose();
  });

  test('app restart restores only valid authorized session', () async {
    final repository = FakeOpsRepository();
    final store = MemoryTokenStore()
      ..access = 'stored-access'
      ..refresh = 'stored-refresh';
    final controller = SessionController(
      repository: repository,
      tokenStore: store,
    );

    await Future<void>.delayed(Duration.zero);

    expect(controller.state.phase, SessionPhase.signedIn);
    expect(controller.state.user?.canVerifyIdentity, isTrue);
    controller.dispose();
  });
}
