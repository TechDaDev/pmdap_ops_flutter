import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pmdap_operations/core/config.dart';
import 'package:pmdap_operations/core/models.dart';
import 'package:pmdap_operations/core/token_store.dart';
import 'package:pmdap_operations/repositories/ops_repository.dart';

enum SessionPhase { restoring, signedOut, signingIn, signedIn }

class SessionState {
  const SessionState({
    required this.phase,
    this.user,
    this.error,
    this.expired = false,
  });

  const SessionState.restoring() : this(phase: SessionPhase.restoring);
  const SessionState.signedOut({String? error, bool expired = false})
    : this(phase: SessionPhase.signedOut, error: error, expired: expired);
  const SessionState.signingIn() : this(phase: SessionPhase.signingIn);
  const SessionState.signedIn(OpsUser user)
    : this(phase: SessionPhase.signedIn, user: user);

  final SessionPhase phase;
  final OpsUser? user;
  final String? error;
  final bool expired;
}

class SessionController extends StateNotifier<SessionState> {
  SessionController({
    required OpsRepository repository,
    required TokenStore tokenStore,
    Duration timeout = AppConfig.sessionTimeout,
  }) : _repository = repository,
       _tokenStore = tokenStore,
       _timeout = timeout,
       super(const SessionState.restoring()) {
    unawaited(restore());
  }

  final OpsRepository _repository;
  final TokenStore _tokenStore;
  final Duration _timeout;
  Timer? _timer;

  Future<void> restore() async {
    final access = await _tokenStore.readAccess();
    final refresh = await _tokenStore.readRefresh();
    if (access == null || refresh == null) {
      state = const SessionState.signedOut();
      return;
    }
    try {
      final user = await _repository.me();
      if (!user.canVerifyIdentity) {
        await _clear();
        state = const SessionState.signedOut(error: 'unsupported_role');
        return;
      }
      state = SessionState.signedIn(user);
      recordActivity();
    } catch (_) {
      await _clear();
      state = const SessionState.signedOut(expired: true);
    }
  }

  Future<void> login(String email, String password) async {
    state = const SessionState.signingIn();
    try {
      final tokens = await _repository.login(email, password);
      await _tokenStore.write(access: tokens.access, refresh: tokens.refresh);
      final user = await _repository.me();
      if (!user.canVerifyIdentity) {
        try {
          await _repository.logout(tokens.refresh);
        } catch (_) {
          // Local credential removal remains mandatory if remote revoke fails.
        }
        await _clear();
        state = const SessionState.signedOut(error: 'unsupported_role');
        return;
      }
      state = SessionState.signedIn(user);
      recordActivity();
    } on ApiFailure catch (error) {
      await _clear();
      state = SessionState.signedOut(error: error.message);
    }
  }

  void recordActivity() {
    if (state.phase != SessionPhase.signedIn) return;
    _timer?.cancel();
    _timer = Timer(_timeout, expire);
  }

  Future<void> logout() async {
    final refresh = await _tokenStore.readRefresh();
    if (refresh != null) {
      try {
        await _repository.logout(refresh);
      } catch (_) {
        // Never retain local credentials because network logout failed.
      }
    }
    await _clear();
    state = const SessionState.signedOut();
  }

  void expire() {
    if (state.phase == SessionPhase.signedOut) return;
    unawaited(_expire());
  }

  Future<void> _expire() async {
    await _clear();
    state = const SessionState.signedOut(expired: true);
  }

  Future<void> _clear() async {
    _timer?.cancel();
    _timer = null;
    await _tokenStore.clear();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
