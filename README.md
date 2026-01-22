# Milkshake

Milkshake bar app (Flutter + Firebase).

## Flutter

- [Install Flutter](https://docs.flutter.dev/get-started/install)

## Demo access

For reviewers/testers:

- **Manager account (email)**: `butizwide@gmail.com`
                               `buti12345`
- **Patron account (email)**: `charlie@gmail.com`
                              `charlie12345`

### Patron flow

- Use **Sign up** to create an account, then place an order.

### Manager access

Manager features (Lookup Management) are gated by a Firebase Auth **custom claim**: `role=manager`.

If you need manager access, the project owner can grant it via the deployed Cloud Function:

- `setUserRole` (requires `ADMIN_TOKEN` secret)

### Email delivery note

SendGrid/Twilio can sometimes take a while to deliver emails (they may show as deferred initially), but they do eventually come through.

