// lib/core/config/gemini_config.dart
class GeminiConfig {
  static const apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'PASTE_KEY_TEMPORARILY',
  );
}
