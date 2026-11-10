# Cloud Courier — Activity 14

**Student:** Akshitha Sainath Sanagarapu  
**Student ID:** 003027780  
**Course:** CSC 4360 / MAD 4360 — Mobile App Development  
**Assignment:** In-Class Activity 14 — Firebase Cloud Messaging  
**Repository:** https://github.com/AkshithaSanagarapu/MAD4360-Activity14-FCM

## About the app

Cloud Courier is a small Flutter app that receives Firebase Cloud Messaging notifications and updates a campus announcement. The app shows which message handler ran, the current asset, a receipt count, and whether the payload was accepted or rejected.

I kept Firebase messaging in `lib/services/fcm_service.dart` so the UI code stays easier to follow. Supported data values are `action=update_ui` and `asset=default` or `asset=promo`. Unknown values are rejected without changing the announcement.

## Run the project

1. Set up Flutter and an Android emulator with Google Play services.
2. Use the Firebase configuration included in the project for its configured Android app.
3. Run `flutter pub get` and `flutter run`.
4. In Firebase Console, send a test notification to the current device registration token, with the custom data shown below. Do not commit or share the token.

**Valid custom data:**

```json
{"action":"update_ui","asset":"promo"}
```

**Invalid custom data for T4:**

```json
{"action":"update_ui","asset":"unknown"}
```

## Test results

Test device: Pixel 10 Android emulator, Android 17 (API 37). Notification permission: authorized. FCM token status: Ready (token not displayed).

| Test | Expected | Observed | Result | Evidence |
|---|---|---|---|---|
| T1: Foreground | `onMessage`; valid promo updates UI | `onMessage`; promo announcement displayed and accepted | Pass | [T1](evidence/T1_Foreground.png) |
| T2: Background tap | `onMessageOpenedApp`; valid promo updates UI | `onMessageOpenedApp`; promo displayed and accepted | Pass | [T2](evidence/T2_BackgroundTap.png) |
| T3: Cold-start tap | `getInitialMessage`; valid promo updates UI | `getInitialMessage`; one receipt this launch; promo accepted | Pass | [T3](evidence/T3_ColdStart.png) |
| T4: Invalid payload in foreground | `onMessage`; reject unknown asset; keep previous UI | `onMessage`; rejection shown; promo title/icon unchanged | Pass | [T4](evidence/T4_InvalidPayload.png) |

**Code checks:** `flutter analyze` reported no issues; `flutter test` passed all 6 tests.

These tests demonstrate behavior on this emulator with notification-plus-data messages. They do not prove guaranteed delivery on every device or network. Android force-stop was avoided during the cold-start test.

## Files to submit

- This GitHub repository, containing the Flutter project
- `evidence/` — four screenshots, one per required test
- `Activity14_Graduate_Reflection.docx` — graduate reflection, test records, and device information

## Assistance

I used ChatGPT to help organize, review, and document the implementation. I ran the emulator tests and checked the observed results.
