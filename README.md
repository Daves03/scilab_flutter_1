# scilab_flutter_1

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Gemini quiz generation

Quiz generation uses `gemini-3.8-flash` by default. Keep the Gemini API key out
of source control by creating an ignored `.gemini.local.json` file:

```json
{
  "GEMINI_API_KEY": "YOUR_GEMINI_API_KEY",
  "GEMINI_MODEL": "gemini-3.8-flash"
}
```

Run or build the app with that configuration:

```sh
flutter run --dart-define-from-file=.gemini.local.json
flutter build web --release --dart-define-from-file=.gemini.local.json
```

Values supplied with `--dart-define` are embedded in Flutter web builds. For a
production deployment, route Gemini requests through Firebase AI Logic with App
Check or through an authenticated server endpoint instead of treating the value
as a browser-side secret.
