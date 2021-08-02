import 'package:flutter/widgets.dart';
import 'package:my_provider/provider.dart';

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

class FetchState<TResponse, TParams> {
  FetchState(
      {this.loading,
      this.response,
      this.error,
      this.exception,
      required this.fetch});

  Function(TParams? params) fetch;
  bool? loading;
  TResponse? response;
  FetchError? error;
  FetchException? exception;
}

class Fetch<TResponse, TParams> extends StatefulWidget {
  static setResponse(String providerKey, dynamic response) {
    Provider(providerKey: providerKey, value: response).setValue(response);
  }

  Fetch(
      {Key? key,
      required this.request,
      required this.builder,
      this.params,
      this.lazy = false,
      this.onSuccess,
      this.onError,
      this.providerKey,
      this.cacheFirst,
      this.cacheDuration,
      this.onInit})
      : super(key: key);

  final String? providerKey;
  final bool lazy;
  final Function(TParams? params) request;
  final Function(FetchState<TResponse, TParams> fetchState) builder;

  final TParams? params;

  final Function(FetchState<TResponse, TParams>)? onInit;

  final Function(TResponse? response, FetchState<TResponse, TParams>)?
      onSuccess;
  final Function(FetchError? response)? onError;

  final bool? cacheFirst;
  final int? cacheDuration;

  @override
  _FetchState createState() => _FetchState<TResponse, TParams>();
}

class _FetchState<TResponse, TParams> extends State<Fetch<TResponse, TParams>> {
  late FetchState<TResponse, TParams> _fetchState;

  bool _disposed = false;

  @override
  void initState() {
    super.initState();

    _fetchState = FetchState(fetch: _request);

    if (widget.providerKey != null && widget.providerKey!.isNotEmpty) {
      Provider.registerCallback(
          ProviderCallback(widget.providerKey!, this._callback));
    }

    if (!widget.lazy) {
      _request(null);
    }
  }

  _callback(value) {
    setState(() {
      _fetchState = FetchState(
          fetch: _request, loading: false, response: value, error: null);
    });
  }

  @override
  void dispose() {
    this._disposed = true;

    super.dispose();
  }

  _request(TParams? params) async {
    try {
      setState(() {
        _fetchState = FetchState(
            fetch: _request, response: _fetchState.response, loading: true);
      });

      var response = params != null
          ? await widget.request(params)
          : await widget.request(widget.params);

      if (this._disposed) {
        return;
      }

      this.setState(() {
        _fetchState = FetchState(
            fetch: _request, loading: false, response: response, error: null);
      });

      if (widget.onSuccess != null) {
        widget.onSuccess!(response, this._fetchState);
      }
    } on FetchError catch (error) {
      if (this._disposed) {
        return;
      }

      this.setState(() {
        _fetchState = FetchState(
            fetch: _request,
            loading: false,
            response: _fetchState.response,
            error: error);
      });

      if (widget.onError != null) {
        widget.onError!(error);
      }
    } on Exception catch (exception) {
      if (this._disposed) {
        return;
      }

      this.setState(() {
        _fetchState = FetchState(
            fetch: _request,
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
