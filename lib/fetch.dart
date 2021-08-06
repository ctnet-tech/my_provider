import 'package:flutter/widgets.dart';
import 'package:my_provider/index.dart';

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
  FetchState(
      {this.loading,
      this.response,
      this.error,
      this.exception,
      required this.fetch,
      required this.initialized});

  Function(dynamic params) fetch;
  bool? loading;
  TResponse? response;
  FetchError? error;
  FetchException? exception;
  bool initialized;
}

class FetchProviderValue<TResponse> {
  FetchProviderValue({this.loading, this.response, this.isForce = false});

  final bool? loading;
  final TResponse? response;
  final bool isForce;
}

class Fetch<TResponse> extends StatefulWidget {
  static setResponse<TR>(String providerKey, TR? response) {
    Provider<FetchProviderValue<TR?>> provider = Provider(providerKey);
    provider.setValue(FetchProviderValue(response: response));
  }

  static forceSetResponse<TR>(String providerKey, TR? response) {
    Provider<FetchProviderValue<TR?>> provider = Provider(providerKey);
    provider.setValue(FetchProviderValue(response: response, isForce: true));
  }

  Fetch(
      {Key? key,
      required this.request,
      required this.builder,
      this.params,
      this.lazy = false,
      this.onSuccess,
      this.onError,
      this.onResponseChange,
      this.providerKey,
      this.cacheFirst = false,
      this.cacheDuration,
      this.onInit,
      this.onResponseExpired})
      : super(key: key);

  final String? providerKey;
  final bool lazy;
  final Function(dynamic params) request;
  final Function(FetchState<TResponse> fetchState) builder;

  final dynamic params;

  final Function(FetchState<TResponse> response)? onInit;

  final Function(TResponse? response, FetchState<TResponse> fetchState)?
      onSuccess;
  final Function(FetchError? response)? onError;
  final Function(TResponse? newResponse, TResponse? oldResponse)?
      onResponseChange;

  final Function(FetchState<TResponse> fetchState)? onResponseExpired;

  final bool cacheFirst;
  final int? cacheDuration;

  bool get isUseProvider => this.providerKey != null;

  @override
  _FetchState createState() => _FetchState<TResponse>();
}

class _FetchState<TResponse> extends State<Fetch<TResponse>> {
  late FetchState<TResponse> _fetchState;

  Provider<FetchProviderValue<TResponse>>? _provider;
  Provider<FetchProviderValue<TResponse>>? get provider =>
      _provider != null ? _provider : Provider(widget.providerKey!);

  bool _disposed = false;

  void _onProviderValueUpdating(dynamic param) {
    var nextFetchState = param.newValue as FetchProviderValue<TResponse>?;

    var needsUpdateState =
        (this._fetchState.response != nextFetchState?.response);

    if (nextFetchState?.isForce == true) {
      needsUpdateState = true;
    }

    if (!needsUpdateState) {
      return;
    }

    setState(() {
      _fetchState = FetchState(
          fetch: _fetchState.fetch,
          initialized: true,
          response: nextFetchState?.response);
    });
  }

  void _onProviderValueExpired(dynamic param) {
    if (widget.onResponseExpired != null) {
      return widget.onResponseExpired!(this._fetchState);
    }
  }

  void _request(dynamic params) async {
    try {
      setState(() {
        _fetchState = FetchState(
            fetch: _request,
            response: _fetchState.response,
            loading: true,
            initialized: true);
      });

      var response = params != null
          ? await widget.request(params)
          : await widget.request(widget.params);

      if (this._disposed) {
        return;
      }

      if (widget.onSuccess != null) {
        widget.onSuccess!(response, this._fetchState);
      }

      this.setState(() {
        _fetchState = FetchState(
            fetch: _request,
            loading: false,
            response: response,
            error: null,
            initialized: true);
      });
    } on FetchError catch (error) {
      if (this._disposed) {
        return;
      }

      this.setState(() {
        _fetchState = FetchState(
            fetch: _request,
            loading: false,
            response: _fetchState.response,
            error: error,
            initialized: true);
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
                exception: exception, message: exception.toString()),
            initialized: true);
      });
    } finally {
      if (widget.isUseProvider) {
        this.provider!.setValue(FetchProviderValue(
            response: this._fetchState.response, loading: false));

        var shouldSetCacheDuration =
            this._fetchState.response != null && widget.cacheDuration != null;

        if (shouldSetCacheDuration) {
          this.provider!.setCacheDuration(widget.cacheDuration!);
        }
      }
    }
  }

  @override
  void initState() {
    this._fetchState = FetchState(fetch: _request, initialized: false);

    var needsSendRequest = false;
    var needsRefetch = false;

    if (widget.isUseProvider) {
      var existingProviderValue =
          this.provider!.getValue<FetchProviderValue<TResponse?>>();

      if (existingProviderValue != null) {
        this._fetchState.response = existingProviderValue.response;
        this._fetchState.loading = existingProviderValue.loading;
        this._fetchState.initialized = true;

        needsRefetch = !widget.lazy &&
            !widget.cacheFirst &&
            existingProviderValue.loading == false;

        if (needsRefetch) {
          this._fetchState.response = null;
        }
      } else {
        this.provider!.setValue(FetchProviderValue(loading: true));
      }

      this.provider!.onUpdating(this._onProviderValueUpdating);
      this.provider!.onExpired(this._onProviderValueExpired);
    }

    needsSendRequest =
        this._fetchState.initialized == false && widget.lazy == false;

    if (widget.onInit != null) {
      widget.onInit!(this._fetchState);
    }

    if (needsSendRequest || needsRefetch) {
      _request(null);
    }

    super.initState();
  }

  @override
  void dispose() {
    this._disposed = true;

    if (widget.isUseProvider) {
      this.provider!.dispose();
    }

    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    final oldRespose = _fetchState.response;
    super.setState(fn);
    final newResponse = _fetchState.response;

    if (oldRespose != newResponse) {
      if (widget.onResponseChange != null) {
        widget.onResponseChange!(newResponse, oldRespose);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return this.widget.builder(_fetchState);
  }
}
