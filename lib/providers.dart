import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pmdap_operations/core/api_client.dart';
import 'package:pmdap_operations/core/models.dart';
import 'package:pmdap_operations/core/token_store.dart';
import 'package:pmdap_operations/features/auth/session_controller.dart';
import 'package:pmdap_operations/repositories/ops_repository.dart';

final tokenStoreProvider = Provider<TokenStore>((ref) => SecureTokenStore());

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(tokenStore: ref.watch(tokenStoreProvider)),
);

final opsRepositoryProvider = Provider<OpsRepository>(
  (ref) => DioOpsRepository(ref.watch(apiClientProvider)),
);

final sessionProvider = StateNotifierProvider<SessionController, SessionState>((
  ref,
) {
  final controller = SessionController(
    repository: ref.watch(opsRepositoryProvider),
    tokenStore: ref.watch(tokenStoreProvider),
  );
  final apiClient = ref.read(apiClientProvider);
  apiClient.onUnauthorized = controller.expire;
  ref.onDispose(() => apiClient.onUnauthorized = null);
  return controller;
});

class DisplayPreferences {
  const DisplayPreferences({required this.themeMode, required this.locale});
  final ThemeMode themeMode;
  final Locale locale;

  DisplayPreferences copyWith({ThemeMode? themeMode, Locale? locale}) =>
      DisplayPreferences(
        themeMode: themeMode ?? this.themeMode,
        locale: locale ?? this.locale,
      );
}

class DisplayPreferencesController extends StateNotifier<DisplayPreferences> {
  DisplayPreferencesController()
    : super(
        const DisplayPreferences(
          themeMode: ThemeMode.system,
          locale: Locale('en'),
        ),
      );

  void setTheme(ThemeMode mode) => state = state.copyWith(themeMode: mode);
  void setLocale(Locale locale) => state = state.copyWith(locale: locale);
}

final displayPreferencesProvider =
    StateNotifierProvider<DisplayPreferencesController, DisplayPreferences>(
      (ref) => DisplayPreferencesController(),
    );

final identityQueueProvider = FutureProvider<Paged<IdentityQueueItem>>(
  (ref) => ref.watch(opsRepositoryProvider).identities(),
);

final identityDetailProvider =
    FutureProvider.family<IdentityReviewDetail, String>(
      (ref, id) => ref.watch(opsRepositoryProvider).identity(id),
    );

final guardianQueueProvider = FutureProvider<Paged<GuardianQueueItem>>(
  (ref) => ref.watch(opsRepositoryProvider).guardians(),
);

final guardianDetailProvider =
    FutureProvider.family<GuardianReviewDetail, String>(
      (ref, id) => ref.watch(opsRepositoryProvider).guardian(id),
    );
