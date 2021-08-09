import 'dart:async';
import 'package:flutter/widgets.dart';
import 'provider.dart';

class FetchException
{
  FetchException({required this.exception, required this.message});

  final Exception exception;
  final String message;
}

class FetchError
{
  FetchError({required this.httpStatus, required this.message});

  final int httpStatus;
  final String message;
}

class FetchState<TResponse, TParams>
{
  FetchState({this.loading,
    this.response,
    this.error,
    this.exception,
    required this.fetch, this.page});

  Function(TParams? params) fetch;
  bool? loading;
  TResponse? response;
  FetchError? error;
  FetchException? exception;
  int? page;
}

class FetchCallback
{
  FetchCallback(this.providerKey, this.callbackFunc);

  final String providerKey;
  final Function(FetchState, bool) callbackFunc;
}

class Fetch<TResponse, TParams> extends StatefulWidget
{
  static Map<String, dynamic> mapFetch = Map();
  static Map<String, bool> mapIsCaching = Map();
  static Map<String, int> mapCurrentPage = Map();
  static List<FetchCallback> callBacksUpdateFetchState = [];

  static registerCallback(FetchCallback fetchCallback)
  {
    Fetch.callBacksUpdateFetchState.add(fetchCallback);
  }

  static setFetchState(String providerKey, dynamic fetchState,
      {bool hasOnSuccess = false})
  {
    mapFetch[providerKey] = fetchState;
    var callbacks = callBacksUpdateFetchState
        .where((element)
    => element.providerKey == providerKey);

    for (var callback in callbacks)
    {
      callback.callbackFunc(fetchState, hasOnSuccess);
    }
  }

  static setResponse(String providerKey, dynamic response)
  {
    Provider(providerKey: providerKey, value: response).setValue(response);
  }

  Fetch({
    Key? key,
    required this.request,
    required this.builder,
    this.params,
    this.lazy = false,
    this.isInfinityScroll = false,
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
  final bool? isInfinityScroll;

  @override
  _FetchState createState()
  => _FetchState<TResponse, TParams>();
}

class _FetchState<TResponse, TParams> extends State<Fetch<TResponse, TParams>>
{
  late FetchState<TResponse, TParams> _fetchState;
  bool _disposed = false;
  int countCacheDuration = 0;
  Timer? _timer;
  int page = 1;

  @override
  void initState()
  {
    if (widget.providerKey != null)
    {
      Provider.registerCallback(ProviderCallback(
          widget.providerKey!, this._onUpdateResponseCallback));
      Fetch.registerCallback(FetchCallback(
        widget.providerKey!,
        this._onUpdateFetchStateCallback,
      ));
      if (Fetch.mapCurrentPage.keys
          .where((element)
      => element == widget.providerKey)
          .isEmpty)
        Fetch.mapCurrentPage[widget.providerKey!] = 1;
    }

    if (widget.cacheFirst != true ||
        Fetch.mapFetch.keys
            .where((element)
        => element == widget.providerKey!)
            .isEmpty)
    {
      _fetchState = FetchState(fetch: _request);
    } else
    {
      _fetchState = Fetch.mapFetch[widget.providerKey!];
      if (widget.onInit != null)
      {
        widget.onInit!(_fetchState);
      }
    }
    if (!widget.lazy)
    {
      if (widget.providerKey == null)
      {
        _request(null);
      } else if (Fetch.mapIsCaching[widget.providerKey!] == false ||
          Fetch.mapFetch.keys
              .where((element)
          => element == widget.providerKey!)
              .isEmpty)
      {
        _request(null);
      }
    }
    if (widget.providerKey != null &&
        Fetch.mapFetch.keys
            .where((element)
        => element == widget.providerKey!)
            .isEmpty) Fetch.mapFetch[widget.providerKey!] = _fetchState;

    super.initState();
  }

  @override
  void dispose()
  {
    Fetch.mapFetch.removeWhere((key, value)
    => key == widget.providerKey);
    Fetch.mapIsCaching.removeWhere((key, value)
    => key == widget.providerKey);
    this._disposed = true;
    if (_timer != null) _timer!.cancel();
    super.dispose();
  }

  _onUpdateResponseCallback(value)
  {
    setState(()
    {
      _fetchState = FetchState(
          fetch: _request, loading: false, response: value, error: null);
    });
  }

  _onUpdateFetchStateCallback(FetchState fetchState, hasOnSuccess)
  {
    if (this._disposed)
    {
      return;
    }
    setState(()
    {
      _fetchState = Fetch.mapFetch[widget.providerKey!];
    });
    if (hasOnSuccess == true)
    {
      if (widget.onSuccess != null)
      {
        widget.onSuccess!(_fetchState.response, _fetchState);
      }
    }
  }

  _request(TParams? params)
  async {
    if (Fetch.mapIsCaching[widget.providerKey] != true)
      try
      {
        if (!(widget.cacheDuration == null && widget.cacheFirst == null))
        {
          Fetch.mapIsCaching[widget.providerKey!] = true;
          _timer = Timer.periodic(Duration(seconds: 1), (timer)
          {
            if (countCacheDuration == widget.cacheDuration)
            {
              countCacheDuration = 0;
              Fetch.mapIsCaching[widget.providerKey!] = false;
              timer.cancel();
            }
            countCacheDuration += 1000;
          });
        }
        if (widget.providerKey == null)
          setState(()
          {
            _fetchState = FetchState(
                fetch: _request, response: _fetchState.response, loading: true);
          });
        else
        {
          _fetchState = FetchState(
              fetch: _request, response: _fetchState.response, loading: true);
          Fetch.setFetchState(
            widget.providerKey!,
            _fetchState,
          );
        }


        var response = params != null
            ? await widget.request(params)
            : await widget.request(widget.params);

        if (widget.isInfinityScroll == true && (_fetchState.response is List || _fetchState.response==null))
        {
          if (widget.providerKey == null)
          {
             page++;
          }
          else
          {
            Fetch.mapCurrentPage[widget.providerKey!] =
                (Fetch.mapCurrentPage[widget.providerKey!] as int) + 1;
          }
          if(_fetchState.response==null)
            {
              _fetchState.response=response;
            }
         else (_fetchState.response as List).addAll(response);
        }
        if (this._disposed)
        {
          return;
        }

        if (widget.providerKey == null)
        {
          this.setState(()
          {
            _fetchState = FetchState(
                fetch: _request,
                loading: false,
                response: widget.isInfinityScroll == true
                    ? _fetchState.response
                    : response,
                error: null,page: widget.providerKey ==null? page: Fetch.mapCurrentPage[widget.providerKey!]);
          });
        } else
        {
          _fetchState = FetchState(
              fetch: _request,
              loading: false,
              response: widget.isInfinityScroll == true
                  ? _fetchState.response
                  : response,
              error: null,page:widget.providerKey ==null? page: Fetch.mapCurrentPage[widget.providerKey!]);
          Fetch.setFetchState(
            widget.providerKey!,
            _fetchState,
            hasOnSuccess: true,
          );
        }

        if (widget.providerKey == null && widget.onSuccess != null)
        {
          widget.onSuccess!(response, _fetchState);
        }
        if (_timer != null && _timer!.isActive)
        {
          _timer!.cancel();
        }
      } on FetchError catch (error)
      {
        if (this._disposed)
        {
          return;
        }

        this.setState(()
        {
          _fetchState = FetchState(
              fetch: _request,
              loading: false,
              response: _fetchState.response,
              error: error);
        });

        if (widget.onError != null)
        {
          widget.onError!(error);
        }
      } on Exception catch (exception)
      {
        if (this._disposed)
        {
          return;
        }

        this.setState(()
        {
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
  Widget build(BuildContext context)
  {
    return this.widget.builder(_fetchState);
  }
}
