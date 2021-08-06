import 'package:my_provider/store.dart';

class Provider<TValue> {
  Provider(this.key);

  final String key;

  bool expired = false;
  int? cacheDuration;

  StoreCallbackFunc<TValue>? _onUpdating;
  StoreCallbackFunc<TValue>? _onExpired;

  void _instanceOnExpired<TValue>(value) {
    expired = true;
  }

  TValue? getValue<TValue>() {
    return Store.getValue(key) as TValue?;
  }

  Provider setValue(TValue? nextValue) {
    Store.setValue(key, nextValue);
    return this;
  }

  Provider setCacheDuration(int msDuration) {
    if (this.cacheDuration == null) {
      Store.addListener(key, _instanceOnExpired, StoreEvent.expired);
    }

    this.cacheDuration = msDuration;
    Store.setCacheDuration<TValue>(key, msDuration);
    return this;
  }

  void onUpdating(StoreCallbackFunc<TValue> callbackFunc) {
    if (_onUpdating != null) {
      Store.unregisterCallback(this._onUpdating!);
    }

    _onUpdating = callbackFunc;
    Store.addListener(key, _onUpdating!, StoreEvent.updating);
  }

  void onExpired(StoreCallbackFunc<TValue> callbackFunc) {
    if (_onExpired != null) {
      Store.unregisterCallback(this._onExpired!);
    }

    _onExpired = callbackFunc;
    Store.addListener(key, _onExpired!, StoreEvent.expired);
  }

  void dispose() {
    if (this.cacheDuration == null) {
      Store.unregisterCallback(this._instanceOnExpired);
    }

    if (this._onUpdating != null) {
      Store.unregisterCallback(this._onUpdating!);
    }

    if (this._onExpired != null) {
      Store.unregisterCallback(this._onUpdating!);
    }
  }
}
