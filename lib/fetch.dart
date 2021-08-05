import 'package:flutter/widgets.dart';
import 'provider.dart';

class FetchCallback {
  FetchCallback(this.providerKey, this.callbackFunc);

  final String providerKey;
  final Function(FetchState, bool) callbackFunc;
}

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
  static Map<String, dynamic> initData = Map();
  static Map<String, bool> expireCache = Map();
  static List<FetchCallback> callBacksUpdateFetchState = [];

  static registerCallback(FetchCallback fetchCallback) {
    Fetch.callBacksUpdateFetchState.add(fetchCallback);
  }

  static setFetchState(String providerKey, dynamic fetchState,
      {bool hasOnSuccess = false}) {
    initData[providerKey] = fetchState;
    var callbacks = callBacksUpdateFetchState
        .where((element) => element.providerKey == providerKey);

    for (var callback in callbacks) {
      callback.callbackFunc(fetchState, hasOnSuccess);
    }
  }

  static setResponse(String providerKey, dynamic response) {
    Provider(providerKey: providerKey, value: response).setValue(response);
  }

  Fetch({
    Key? key,
    required this.request,
    required this.builder,
    this.params,
    this.lazy = false,
    this.onSuccess,
    this.onError,
    this.providerKey,
    this.cacheFirst,
    this.cacheDuration,
    this.onInit,
  }) : super(key: key);

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
  int cacheSetCount = 0;

  get _providerKey => widget.providerKey;

  get _initData => Fetch.initData[_providerKey!];

  bool get isProviderKeyEmpty =>
      Fetch.initData.keys.where((element) => element == _providerKey!).isEmpty;

  @override
  void initState() {
    super.initState();

    if (_providerKey != null) {
      Provider.registerCallback(
          ProviderCallback(_providerKey!, this._callBackResponse));

      Fetch.registerCallback(FetchCallback(
        _providerKey!,
        this._onUpdateFetchStateCallback,
      ));
    }

    if (widget.cacheFirst != true || isProviderKeyEmpty) {
      _fetchState = FetchState(fetch: _request);
    } else {
      _fetchState = _initData;
      if (widget.onInit != null) {
        widget.onInit!(_fetchState);
      }
    }

    if (!widget.lazy) {
      if (_providerKey == null || isProviderKeyEmpty) {
        _request(null);
      }
    }

    if (_providerKey != null && isProviderKeyEmpty)
      Fetch.initData[_providerKey!] = _fetchState;
  }

  @override
  void dispose() {
    this._disposed = true;
    Fetch.initData.removeWhere((key, value) => key == _providerKey);
    Fetch.expireCache.removeWhere((key, value) => key == _providerKey);
    super.dispose();
  }

  _callBackResponse(value) {
    setState(() {
      _fetchState = FetchState(
          fetch: _request, loading: false, response: value, error: null);
    });
  }

  _onUpdateFetchStateCallback(FetchState fetchState, hasOnSuccess) {
    if (this._disposed) {
      return;
    }
    setState(() {
      _fetchState = _initData;
    });

    if (hasOnSuccess == true) {
      if (widget.onSuccess != null) {
        widget.onSuccess!(_fetchState.response, _fetchState);
      }
    }
  }

  _request(TParams? params) async {
    try {
      setState(() {
        _fetchState = FetchState(
            fetch: _request, response: _fetchState.response, loading: true);
      });

      if (_providerKey != null) {
        Fetch.setFetchState(_providerKey!, _fetchState);
      }

      var response = params != null
          ? await widget.request(params)
          : await widget.request(widget.params);

      if (this._disposed) {
        return;
      }
      
      this.setState(() => _fetchState = FetchState(
            fetch: _request,
            loading: false,
            response: response,
            error: null,
          ));

      if (_providerKey == null) {
        if (widget.onSuccess != null) {
          widget.onSuccess!(response, _fetchState);
        }
      } else {
        _fetchState = FetchState(
            fetch: _request, loading: false, response: response, error: null);

        Fetch.setFetchState(_providerKey!, _fetchState, hasOnSuccess: true);
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
