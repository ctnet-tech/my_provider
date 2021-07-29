import 'package:flutter/widgets.dart';
import 'package:my_provider/provider.dart';

class Consumer<TValue> extends StatefulWidget {
  Consumer({required this.providerKey, required this.builder});

  final String providerKey;
  final Function(BuildContext context, TValue child) builder;

  @override
  _ConsumerState<TValue> createState() => _ConsumerState<TValue>();
}

class _ConsumerState<TValue> extends State<Consumer<TValue>> {
  late TValue _value;

  @override
  void initState() {
    super.initState();

    _value = this._getValue();

    Provider.registerCallback(
        ProviderCallback(widget.providerKey, this._onUpdateCallback));
  }

  @override
  void dispose() {
    super.dispose();
    Provider.unregisterCallback(this._onUpdateCallback);
  }

  void _onUpdateCallback(TValue nextValue) {
    this.setState(() {
      _value = nextValue;
    });
  }

  TValue _getValue() {
    return Provider.providers[widget.providerKey];
  }

  @override
  Widget build(BuildContext context) {
    return this.widget.builder(context, this._value);
  }
}
