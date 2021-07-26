typedef ProviderCallbackFunc<TValue> = void Function(TValue value);

class ProviderCallback<TValue> {
  ProviderCallback(this.providerKey, this.callbackFunc);

  final String providerKey;
  final ProviderCallbackFunc<TValue> callbackFunc;
}

class Provider<TValue> {
  static Map<String, dynamic> providers = Map();
  static List<ProviderCallback> callbacks = [];

  static registerCallback<TConsumerValue>(
      ProviderCallback<TConsumerValue> providerCallback) {
    Provider.callbacks.add(providerCallback);
  }

  static unregisterCallback<TConsumerValue>(
      ProviderCallbackFunc<TConsumerValue> callbackFunc) {
    Provider.callbacks
        .removeWhere((element) => element.callbackFunc == callbackFunc);
  }

  Provider({required this.providerKey, this.value}) {
    Provider.providers[providerKey] = value;
  }

  final String providerKey;
  final TValue? value;

  void _runCallbackBeforeUpdate(TValue nextValue) {
    var callbacks = Provider.callbacks
        .where((element) => element.providerKey == this.providerKey);

    for (var callback in callbacks) {
      callback.callbackFunc(nextValue);
    }
  }

  setValue(TValue nextValue) {
    _runCallbackBeforeUpdate(nextValue);

    Provider.providers[providerKey] = nextValue;
  }

  dispose() {
    throw UnimplementedError();
  }
}
