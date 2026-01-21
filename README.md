# Milkshake

Milkshake bar app (Flutter + Firebase).

## Firebase setup (required)

These files are intentionally **not** committed to git:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

Templates are provided:

- `android/app/google-services.json.template`
- `ios/Runner/GoogleService-Info.plist.template`

To run the app locally:

- **Android**: Firebase Console → Project settings → Your apps (Android) → download `google-services.json` → place it at `android/app/google-services.json`.
- **iOS**: Firebase Console → Project settings → Your apps (iOS) → download `GoogleService-Info.plist` → place it at `ios/Runner/GoogleService-Info.plist`.

## Flutter

- [Install Flutter](https://docs.flutter.dev/get-started/install)

## Demo access

For reviewers/testers:

- **Manager account (email)**: `butizwide@gmail.com`
- **Patron account (email)**: `charlie@gmail.com`

### Patron flow

- Use **Sign up** to create an account, then place an order.

### Manager access

Manager features (Lookup Management) are gated by a Firebase Auth **custom claim**: `role=manager`.

If you need manager access, the project owner can grant it via the deployed Cloud Function:

- `setUserRole` (requires `ADMIN_TOKEN` secret)

### Email delivery note

SendGrid/Twilio can sometimes take a while to deliver emails (they may show as deferred initially), but they do eventually come through.

