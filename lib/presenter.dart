import 'package:flutter/widgets.dart';
import 'package:my_dispatcher/dispatcher.dart';

import 'helpers/index.dart';

class Presenter<TValue> extends StatefulWidget {
  Presenter({required this.cacheKey, required this.builder});

  final String cacheKey;
  final Function(BuildContext context, TValue? child) builder;

  @override
  _PresenterState<TValue> createState() => _PresenterState<TValue>();
}

class _PresenterState<TValue> extends State<Presenter<TValue>> {
  late TValue? _value;

  Dispatcher<TValue?>? _dispatcher;
  Dispatcher<TValue?> get dispatcher =>
      _dispatcher != null ? _dispatcher! : Dispatcher(widget.cacheKey);

  void _onUpdateCallback(StoreCallbackParam<TValue?> params) {
    this.setState(() {
      _value = params.newValue;
    });
  }

  @override
  void initState() {
    _value = dispatcher.getValue();

    dispatcher.onUpdating(this._onUpdateCallback);

    super.initState();
  }

  @override
  void dispose() {
    dispatcher.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return this.widget.builder(context, this._value);
  }
}
