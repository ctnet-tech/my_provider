import 'package:flutter/widgets.dart';

class FetchException {
  FetchException({required this.exception, required this.message});

  final Exception exception;
  final String message;
}

class FetchError {
  FetchError({required this.httpStatus, required this.message});

  final int httpStatus;
  final String message;
}

class FetchState<TResponse> {
  FetchState({this.loading, this.response, this.error, this.exception});

  bool? loading;
  TResponse? response;
  FetchError? error;
  FetchException? exception;
}

class Fetch<TResponse> extends StatefulWidget {
  Fetch({Key? key, required this.request, required this.builder})
      : super(key: key);

  final Function() request;
  final Function(FetchState<TResponse> fetchState) builder;

  @override
  _FetchState createState() => _FetchState<TResponse?>();
}

class _FetchState<TResponse> extends State<Fetch<TResponse>> {
  FetchState<TResponse> _fetchState = FetchState();

  @override
  void initState() {
    super.initState();
    _request();
  }

  _request() async {
    try {
      setState(() {
        _fetchState = FetchState(response: _fetchState.response, loading: true);
      });

      var response = await widget.request();

      if (response is FetchError) {
        this.setState(() {
          _fetchState = FetchState<TResponse>(
              loading: false, response: _fetchState.response, error: response);
        });
      } else {
        this.setState(() {
          _fetchState = FetchState<TResponse>(
              loading: false, response: response, error: null);
        });
      }
    } on Exception catch (exception) {
      this.setState(() {
        _fetchState = FetchState<TResponse>(
            loading: false,
            response: _fetchState.response,
            exception: FetchException(
                exception: exception, message: exception.toString()));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return this.widget.builder(_fetchState);
  }
}
