import 'package:my_dispatcher/store.dart';

import 'helpers/index.dart';

class Dispatcher<TValue> {
  static Dispatcher<TValue>? existingOrNull<TValue>(dynamic key) {
    if (Store.isExisting(key)) {
      return Dispatcher(key);
    }

    return null;
  }

  Dispatcher(this.key);

  final dynamic key;

  bool expired = false;
  int? cacheDuration;

  StoreCallbackFunc<TValue>? _onUpdating;
  StoreCallbackFunc<TValue>? _onExpired;

  void _instanceOnExpired<TValue>(value) {
    expired = true;
  }

  TValue? getValue() {
    return Store.getValue(key) as TValue?;
  }

  Dispatcher<TValue> setValue(TValue? nextValue) {
    Store.setValue(key, nextValue);
    return this;
  }

  Dispatcher<TValue> setInitialValue(TValue? nextValue) {
    Store.setInitialValue(key, nextValue);
    return this;
  }

  Dispatcher<TValue> setCacheDuration(int? msDuration) {
    if (msDuration == null) {
      return this;
    }

    if (this.cacheDuration == null) {
      Store.registerEvent(key, _instanceOnExpired, StoreEvent.expired);
    }

    this.cacheDuration = msDuration;
    Store.setCacheDuration<TValue>(key, msDuration);
    return this;
  }

  Dispatcher<TValue> onUpdating(StoreCallbackFunc<TValue> callbackFunc) {
    if (_onUpdating != null) {
      Store.unregisterEvent(this._onUpdating!);
    }

    _onUpdating = callbackFunc;
    Store.registerEvent(key, _onUpdating!, StoreEvent.updating);

    return this;
  }

  Dispatcher<TValue> onExpired(StoreCallbackFunc<TValue> callbackFunc) {
    if (_onExpired != null) {
      Store.unregisterEvent(this._onExpired!);
    }

    _onExpired = callbackFunc;
    Store.registerEvent(key, _onExpired!, StoreEvent.expired);

    return this;
  }

  bool compareKey(dynamic rawKey) {
    return StoreKeys.fromRaw(rawKey) == StoreKeys.fromRaw(this.key);
  }

  void dispose() {
    if (this.cacheDuration == null) {
      Store.unregisterEvent(this._instanceOnExpired);
    }

    if (this._onUpdating != null) {
      Store.unregisterEvent(this._onUpdating!);
    }

    if (this._onExpired != null) {
      Store.unregisterEvent(this._onUpdating!);
    }
  }
}
