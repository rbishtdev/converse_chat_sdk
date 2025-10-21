import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';

/// Initializes Firebase safely for the Chat SDK.
///
/// Ensures Firebase is initialized exactly once — even if
/// called multiple times across different SDK layers.
///
/// Use this at the start of your app or before creating
/// any Firebase repository instances.
class FirebaseAdapterInitializer {
  static bool _initialized = false;

  /// Ensures that Firebase is initialized.
  ///
  /// - On mobile/desktop: calls [Firebase.initializeApp] if no app exists.
  /// - On web: reuses the existing Firebase app if already initialized.
  /// - Throws [SDKInitializationException] on failure.
  static Future<void> ensureInitialized({
    FirebaseOptions? options,
  }) async {
    if (_initialized) return;

    try {
      // 🟢 Already initialized — skip
      if (Firebase.apps.isNotEmpty) {
        _initialized = true;
        return;
      }

      // 🟣 Initialize for the first time
      if (options != null) {
        await Firebase.initializeApp(options: options);
      } else {
        await Firebase.initializeApp();
      }

      _initialized = true;
    } catch (e, stack) {
      // ❌ Wrap and rethrow in SDK-level exception
      throw SDKInitializationException(
        'Failed to initialize Firebase: $e',
        stack,
      );
    }
  }

  /// Verifies if Firebase is initialized.
  ///
  /// Returns `true` if at least one Firebase app is active.
  static bool get isInitialized {
    return Firebase.apps.isNotEmpty && _initialized;
  }

  /// Debug utility: prints all registered Firebase apps.
  static void debugPrintApps() {
    if (kDebugMode) {
      for (final app in Firebase.apps) {
        debugPrint('🔥 Firebase app: ${app.name}');
      }
    }
  }
}
