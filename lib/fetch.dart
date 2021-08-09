import 'package:flutter/widgets.dart';
import 'package:my_dispatcher/index.dart';

import 'helpers/index.dart';

class Fetch<TResponse> extends StatefulWidget {
  static setResponse<TR>(dynamic cacheKey, TR? response) {}

  static FetchController? getController(String fetchName) {
    final controllerDispatcher = Dispatcher.existingOrNull<FetchController>(
        [FETCH_CONTROLLERS_BASE_KEY, fetchName]);

    if (controllerDispatcher == null) {
      return null;
    }

    return controllerDispatcher.getValue();
  }

  Fetch(
      {Key? key,
      required this.request,
      required this.builder,
      this.name,
      this.params,
      this.lazy = false,
      this.onSuccess,
      this.onError,
      this.onResponseChange,
      this.cacheFirst = false,
      this.onInit,
      this.onCacheExpired,
      this.createCache})
      : super(key: key) {
    if (this.name != null) {
      this._setupController();
    }
  }

  @override
  _FetchState createState() => _FetchState<TResponse>();

  final String? name;
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

  final Function(
          FetchCache<TResponse?> cache, FetchState<TResponse> fetchState)?
      onCacheExpired;

  final FetchCache<TResponse?> Function(dynamic params, TResponse? response)?
      createCache;

  final bool cacheFirst;

  final List<Dispatcher<FetchCache<TResponse?>>> fetchCacheDispatchers = [];

  List<FetchCache<TResponse?>> get fetchCaches {
    return fetchCacheDispatchers
        .where((element) => element.getValue() != null)
        .map<FetchCache<TResponse?>>((e) => e.getValue()!)
        .toList();
  }

  Dispatcher<FetchController>? _controllerDispatcher;

  void _setupController() {
    final controllerDispatcher =
        Dispatcher<FetchController>([FETCH_CONTROLLERS_BASE_KEY, this.name]);
    final existingController = controllerDispatcher.getValue();
    if (existingController != null) {
      throw FetchError(message: "The Fetch's name \"${this.name}\" is used!");
    }
    this._controllerDispatcher = controllerDispatcher;
  }
}

class _FetchState<TResponse> extends State<Fetch<TResponse>> {
  late FetchState<TResponse> _fetchState;

  void _onDispatcherValueUpdating(dynamic param) {
    var nextFetchState = param.newValue as FetchCache<TResponse?>?;

    var needsUpdateState =
        this._fetchState.fetchingStatus != FetchingStatus.begingFetch &&
            (this._fetchState.response != nextFetchState?.response);

    if (!needsUpdateState) {
      return;
    }

    setState(() {
      _fetchState = FetchState(
          fetch: _fetchState.fetch,
          loading: false,
          response: nextFetchState?.response,
          fetchingStatus: FetchingStatus.nothing,
          caches: widget.fetchCaches);
    });
  }

  void _onDispatcherValueExpired(
      StoreCallbackParam<FetchCache<TResponse?>> param) {
    if (widget.onCacheExpired != null) {
      return widget.onCacheExpired!(param.oldValue!, this._fetchState);
    }
  }

  Future<void> _prepareRequest(dynamic params) async {
    final requestParams = params ?? widget.params;

    FetchCache<TResponse?>? existingCache;
    if (widget.createCache != null) {
      var fetchCache = widget.createCache!(requestParams, _fetchState.response);
      var existingDispatcher = widget.fetchCacheDispatchers
          .firstWhere((p) => p.compareKey(fetchCache.key), orElse: () {
        var newDispatcher = Dispatcher<FetchCache<TResponse?>>(fetchCache.key)
            .onUpdating(this._onDispatcherValueUpdating)
            .onExpired(this._onDispatcherValueExpired);
        widget.fetchCacheDispatchers.add(newDispatcher);
        return newDispatcher;
      });

      if (widget.cacheFirst) {
        existingCache = existingDispatcher.getValue();

        if (existingCache == null) {
          fetchCache.waiting = true;
          existingDispatcher = existingDispatcher.setInitialValue(fetchCache);
        }

        if (existingCache?.waiting == true) {
          setState(() {
            _fetchState = FetchState(
                fetch: _prepareRequest,
                response: _fetchState.response,
                params: requestParams,
                loading: true,
                fetchingStatus: FetchingStatus.waitingForCache,
                caches: widget.fetchCaches);
          });

          return;
        }
      }

      if (existingCache != null) {
        this.setState(() {
          _fetchState = FetchState(
              fetch: _prepareRequest,
              params: requestParams,
              response: existingCache!.response,
              loading: false,
              error: null,
              exception: null,
              fetchingStatus: FetchingStatus.nothing,
              caches: widget.fetchCaches);
        });
        return;
      }
    }

    this.setState(() {
      _fetchState = FetchState(
          fetch: _prepareRequest,
          response: _fetchState.response,
          params: requestParams,
          loading: true,
          fetchingStatus: FetchingStatus.begingFetch,
          caches: widget.fetchCaches);
    });
  }

  Future<void> _runRequest() async {
    var requestParams = this._fetchState.params;

    FetchException? exception;
    FetchError? error;
    TResponse? response;

    try {
      response = await widget.request(requestParams);

      if (widget.onSuccess != null) {
        widget.onSuccess!(response, this._fetchState);
      }
    } on FetchError catch (e) {
      error = e;
      response = this._fetchState.response;
      if (widget.onError != null) {
        widget.onError!(error);
      }
    } on Exception catch (e) {
      response = this._fetchState.response;
      exception = FetchException(exception: e, message: e.toString());
    } finally {
      if (!this.mounted) {
        // ignore: control_flow_in_finally
        return;
      }

      if (widget.createCache != null) {
        final fetchCache =
            widget.createCache!(requestParams, this._fetchState.response);

        fetchCache.response = response;

        final existingDispatcher = widget.fetchCacheDispatchers
            .firstWhere((p) => p.compareKey(fetchCache.key));

        existingDispatcher
            .setValue(fetchCache)
            .setCacheDuration(fetchCache.duration);
      }

      this.setState(() {
        _fetchState = FetchState(
            fetch: _prepareRequest,
            loading: false,
            response: response,
            params: requestParams,
            exception: exception,
            error: error,
            fetchingStatus: FetchingStatus.nothing,
            caches: widget.fetchCaches);
      });
    }
  }

  void _onControllerAction(FetchControllerAction action, dynamic params) {
    switch (action) {
      case FetchControllerAction.setCache:
        final cache = params as FetchCache;

        final dispatcher =
            Dispatcher.existingOrNull<FetchCache<TResponse?>>(cache.key);
        if (dispatcher == null) {
          return;
        }

        dispatcher.setValue(FetchCache(
            response: cache.response,
            key: cache.key,
            duration: cache.duration));
        break;
      case FetchControllerAction.fetch:
        this._prepareRequest(params);
        break;
      case FetchControllerAction.setResponse:
        this.setState(() {
          _fetchState = FetchState(
              response: params,
              loading: _fetchState.loading,
              caches: _fetchState.caches,
              fetch: _fetchState.fetch,
              fetchingStatus: _fetchState.fetchingStatus,
              error: _fetchState.error,
              exception: _fetchState.exception,
              params: _fetchState.params);
        });
        break;
      default:
        break;
    }
  }

  @override
  void initState() {
    if (widget._controllerDispatcher != null) {
      final newController =
          FetchController(widget.name!, listener: _onControllerAction);

      widget._controllerDispatcher!.setValue(newController);
    }

    this._fetchState = FetchState(
        fetch: _prepareRequest,
        params: widget.params,
        loading: false,
        fetchingStatus: FetchingStatus.nothing,
        caches: []);

    var needsSendRequest = widget.lazy == false;

    if (widget.onInit != null) {
      widget.onInit!(this._fetchState);
    }

    if (needsSendRequest) {
      _prepareRequest(null);
    }

    super.initState();
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
    if (this._fetchState.fetchingStatus == FetchingStatus.begingFetch) {
      Future.microtask(_runRequest);
    }
    return this.widget.builder(_fetchState);
  }

  @override
  void dispose() {
    for (var fetchCacheDispatcher in widget.fetchCacheDispatchers) {
      Store.remove(fetchCacheDispatcher.key);
    }

    if (widget._controllerDispatcher != null) {
      Store.remove(widget._controllerDispatcher!.key);
    }

    super.dispose();
  }
}
