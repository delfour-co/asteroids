import 'dart:developer' as dev;

/// Log an error. Console output only for now; Crashlytics added later.
void logError(String system, String message, [Object? error]) {
  dev.log('[$system] ERROR: $message', error: error);
}

/// Log a warning. Console output only for now; Crashlytics added later.
void logWarn(String system, String message) {
  dev.log('[$system] WARN: $message');
}
