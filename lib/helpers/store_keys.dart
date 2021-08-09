import 'store_constants.dart';

abstract class StoreKeys {
  static final keyRule = RegExp(r'^[a-zA-Z0-9_-]+$');

  static getEventKey(String key, StoreEvent storeEvent) {
    var storeEventName = storeEvent.toString();

    return "${key}_$storeEventName".toUpperCase();
  }

  static String fromRaw(dynamic rawKey) {
    var key = "";
    final separator = "/";

    if (rawKey is String) {
      key = rawKey;
    } else if (rawKey is List) {
      for (var part in rawKey) {
        final isKeyValid = StoreKeys.validateKey(part.toString());
        if (!isKeyValid) {
          throw StoreError("INVALID_STORE_KEY_CONTENT");
        }
      }
      key = rawKey.join(separator);
    } else {
      throw StoreError("INVALID_STORE_KEY");
    }

    return key;
  }

  static bool validateKey(String key) {
    return StoreKeys.keyRule.hasMatch(key);
  }
}
