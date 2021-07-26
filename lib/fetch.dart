import 'package:flutter/widgets.dart';

class Fetch<TResponse> extends StatefulWidget {
  Fetch({Key? key, required this.request, required this.builder})
      : super(key: key);

  final Function() request;
  final Function(TResponse? response) builder;

  @override
  _FetchState createState() => _FetchState<TResponse?>();
}

class _FetchState<TResponse> extends State<Fetch<TResponse>> {
  TResponse? _response;

  @override
  void initState() {
    super.initState();
    _request();
  }

  _request() async {
    var response = await widget.request();
    this.setState(() {
      _response = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return this.widget.builder(_response);
  }
}
