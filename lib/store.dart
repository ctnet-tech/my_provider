import 'dart:async';

import 'helpers/index.dart';

abstract class Store {
  static Map<String, dynamic> _cacheValues = Map();
  static List<StoreSubscriber> _subscribers = [];

  static registerEvent<TPresenterValue>(dynamic rawKey,
      StoreCallbackFunc<TPresenterValue> callback, StoreEvent storeEvent) {
    final key = StoreKeys.fromRaw(rawKey);
    final eventKey = StoreKeys.getEventKey(key, storeEvent);
    final eventEmitter =
        EventEmitter.addListener<StoreCallbackParam<TPresenterValue?>>(
            eventKey, callback);

    _subscribers.add(StoreSubscriber(key, eventEmitter, StoreEvent.updated));
  }

  static unregisterEvent<TPresenterValue>(
      StoreCallbackFunc<TPresenterValue> storeCallback) {
    final removingSubscribers = Store._subscribers
        .where((e) => e.eventListener.listener == storeCallback)
        .toList();

    for (final removingSubscriber in removingSubscribers) {
      EventEmitter.removeListener(removingSubscriber.key, removingSubscriber);
      Store._subscribers.remove(removingSubscriber);
    }
  }

  static setCacheDuration<TValue>(dynamic rawKey, int msDuration) {
    final key = StoreKeys.fromRaw(rawKey);

    Timer(Duration(milliseconds: msDuration), () {
      Store._onCacheExpired<TValue>(key);
    });
  }

  static setInitialValue<TValue>(dynamic rawKey, TValue value) {
    final key = StoreKeys.fromRaw(rawKey);

    if (_cacheValues.containsKey(key)) {
      return;
    }

    Store._cacheValues[key] = value;
  }

  static setValue<TValue>(dynamic rawKey, TValue value) {
    final key = StoreKeys.fromRaw(rawKey);

    _emitUpdatings<TValue>(key, value);
    Store._cacheValues[key] = value;
  }

  static getValue(dynamic rawKey) {
    final key = StoreKeys.fromRaw(rawKey);

    return Store._cacheValues[key];
  }

  static isExisting(dynamic rawKey) {
    final key = StoreKeys.fromRaw(rawKey);
    return _cacheValues.containsKey(key);
  }

  static remove<TValue>(dynamic rawKey) {
    final key = StoreKeys.fromRaw(rawKey);
    _removeSubscribers(key);
    Store._cacheValues.remove(key);
  }

  static _removeSubscribers(String key) {
    _subscribers.where((e) => e.key == key).forEach((e) {
      EventEmitter.removeListener(
          e.eventListener.eventKey, e.eventListener.listener);
    });
    _subscribers.removeWhere((e) => e.key == key);
  }

  static _onCacheExpired<TValue>(String key) {
    final oldValue = getValue(key) as TValue?;

    Store._cacheValues.remove(key);
    Store._emitExpireds<TValue>(key, oldValue);
  }

  static _emitUpdatings<TValue>(String key, dynamic newValue) {
    final eventKey = StoreKeys.getEventKey(key, StoreEvent.updating);

    EventEmitter.emit(
        eventKey,
        StoreCallbackParam<TValue>(key,
            currentValue: getValue(key), newValue: newValue));
  }

  static _emitExpireds<TValue>(String key, dynamic oldValue) {
    final eventKey = StoreKeys.getEventKey(key, StoreEvent.expired);
    final eventParams =
        StoreCallbackParam<TValue>(key, oldValue: oldValue, newValue: null);
    EventEmitter.emit(eventKey, eventParams);
  }
}
