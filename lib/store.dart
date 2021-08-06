import 'dart:async';

import 'package:my_provider/event_emitter.dart';

enum StoreEvent { updating, updated, expired }

typedef StoreCallbackFunc<TValue> = void Function(
    StoreCallbackParam<TValue> value);

class StoreSubscriber<TValue> {
  StoreSubscriber(this.key, this.eventListener, this.storeEvent);

  final String key;
  final StoreEvent storeEvent;
  final EventListener<StoreCallbackParam<TValue>> eventListener;
}

class StoreCallbackParam<TValue> {
  StoreCallbackParam(this.key,
      {this.currentValue, this.newValue, this.oldValue});

  final String key;

  final TValue? currentValue;
  final TValue? newValue;
  final TValue? oldValue;
}

class Store {
  static Map<String, dynamic> _providers = Map();
  static List<StoreSubscriber> _subscribers = [];

  static addListener<TConsumerValue>(String key,
      StoreCallbackFunc<TConsumerValue> callback, StoreEvent storeEvent) {
    var eventKey = getEventKey(key, storeEvent);
    var eventEmitter =
        EventEmitter.addListener<StoreCallbackParam<TConsumerValue?>>(
            eventKey, callback);

    _subscribers.add(StoreSubscriber(key, eventEmitter, StoreEvent.updated));
  }

  static unregisterCallback<TConsumerValue>(
      StoreCallbackFunc<TConsumerValue> storeCallback) {
    var removingSubscribers = Store._subscribers
        .where((e) => e.eventListener.listener == storeCallback);

    for (var removingSubscriber in removingSubscribers) {
      EventEmitter.removeListener(removingSubscriber.key, removingSubscriber);
      Store._subscribers.remove(removingSubscriber);
    }
  }

  static setCacheDuration<TValue>(String key, int msDuration) {
    Timer(Duration(milliseconds: msDuration), () {
      Store._onCacheExpired<TValue>(key);
    });
  }

  static setValue<TValue>(String key, TValue value) {
    _dispathUpdating<TValue>(key, value);
    Store._providers[key] = value;
  }

  static getValue(String key) {
    return Store._providers[key];
  }

  static getEventKey(String key, StoreEvent storeEvent) {
    var storeEventName = storeEvent.toString();

    return "${key}_$storeEventName".toUpperCase();
  }

  static _onCacheExpired<TValue>(String key) {
    var oldValue = getValue(key) as TValue;

    Store._providers.remove(key);
    Store._dispathExpired<TValue>(key, oldValue);
  }

  static _dispathUpdating<TValue>(String key, dynamic newValue) {
    var eventKey = getEventKey(key, StoreEvent.updating);

    EventEmitter.emit(
        eventKey,
        StoreCallbackParam<TValue>(key,
            currentValue: getValue(key), newValue: newValue));
  }

  static _dispathExpired<TValue>(String key, dynamic oldValue) {
    var eventKey = getEventKey(key, StoreEvent.expired);
    var eventParams =
        StoreCallbackParam<TValue>(key, oldValue: oldValue, newValue: null);
    EventEmitter.emit(eventKey, eventParams);
  }
}
