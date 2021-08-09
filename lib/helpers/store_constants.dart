import 'event_emitter.dart';

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

class StoreError extends Error {
  StoreError(this.message) : super();

  final String message;
}
