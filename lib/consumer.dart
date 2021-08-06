import 'package:flutter/widgets.dart';
import 'package:my_provider/provider.dart';
import 'package:my_provider/store.dart';

class Consumer<TValue> extends StatefulWidget {
  Consumer({required this.providerKey, required this.builder});

  final String providerKey;
  final Function(BuildContext context, TValue? child) builder;

  @override
  _ConsumerState<TValue> createState() => _ConsumerState<TValue>();
}

class _ConsumerState<TValue> extends State<Consumer<TValue>> {
  late TValue? _value;

  Provider<TValue?>? _provider;
  Provider<TValue?> get provider =>
      _provider != null ? _provider! : Provider(widget.providerKey);

  void _onUpdateCallback(StoreCallbackParam<TValue?> params) {
    this.setState(() {
      _value = params.newValue;
    });
  }

  @override
  void initState() {
    _value = provider.getValue();

    provider.onUpdating(this._onUpdateCallback);

    super.initState();
  }

  @override
  void dispose() {
    provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return this.widget.builder(context, this._value);
  }
}
