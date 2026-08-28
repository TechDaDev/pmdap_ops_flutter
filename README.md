# PMDAP Operations

Android-first staff client for PMDAP identity-document and guardian-relationship
review. Access is limited by the backend-provided `can_verify_identity`
capability.

## Run

```bash
flutter pub get
flutter run --dart-define=PMDAP_API_BASE_URL=https://pmdapbackend.up.railway.app
```

The production API URL is the default. Override it with
`PMDAP_API_BASE_URL` for local synthetic testing.

## Quality gates

```bash
flutter gen-l10n
dart format --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --debug
flutter build apk --release
```

The app stores JWTs only through Android encrypted secure storage, applies
`FLAG_SECURE`, fetches identity images as authenticated in-memory bytes, and
clears credentials on logout, expiry, inactivity, and unauthorized responses.
