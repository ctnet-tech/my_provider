class EventListener<TParam> {
  EventListener(this.eventKey, this.listener);

  final String eventKey;
  final Function(TParam params) listener;

  void emit(TParam param) {
    listener(param);
  }
}

class EventEmitter {
  static List<EventListener> _eventListeners = [];

  static EventListener<TValue> addListener<TValue>(eventKey, listener) {
    var eventListener = EventListener<TValue>(eventKey, listener);
    _eventListeners.add(eventListener);
    return eventListener;
  }

  static removeListener(eventKey, listener) {
    _eventListeners
        .removeWhere((e) => e.eventKey == eventKey && e.listener == listener);
  }

  static emit<TParam>(eventKey, param) {
    var emittingEventListeners =
        _eventListeners.where((element) => element.eventKey == eventKey);

    emittingEventListeners.forEach((element) {
      element.emit(param);
    });
  }
}
