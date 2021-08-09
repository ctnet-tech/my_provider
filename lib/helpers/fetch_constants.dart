const FETCH_CONTROLLERS_BASE_KEY = "FETCH_CONTROLLERS";

class FetchException {
  FetchException({required this.exception, required this.message});

  final Exception exception;
  final String message;
}

class FetchError extends Error {
  FetchError({required this.message, this.httpStatus});

  final int? httpStatus;
  final String message;
}

enum FetchingStatus { nothing, begingFetch, waitingForCache }

class FetchState<TResponse> {
  FetchState(
      {required this.loading,
      this.params,
      this.response,
      this.error,
      this.exception,
      required this.fetch,
      required this.fetchingStatus,
      required this.caches});

  Function(dynamic params) fetch;
  bool loading;
  TResponse? response;
  FetchError? error;
  FetchException? exception;
  final dynamic params;
  final FetchingStatus fetchingStatus;
  final List<FetchCache<TResponse?>> caches;
}

class FetchCache<TResponse> {
  FetchCache({
    required this.key,
    this.duration,
    this.response,
    this.waiting = false,
  });
  final dynamic key;
  final int? duration;

  TResponse? response;
  bool waiting;
}

enum FetchControllerAction { setCache, fetch, setResponse }

class FetchController {
  FetchController(this.fetchName, {required this.listener});
  final String fetchName;
  final Function(FetchControllerAction action, dynamic params) listener;

  FetchController setCache(FetchCache cache) {
    listener.call(FetchControllerAction.setCache, cache);
    return this;
  }

  FetchController fetch(dynamic params) {
    listener.call(FetchControllerAction.fetch, params);
    return this;
  }

  FetchController setResponse(dynamic response) {
    listener.call(FetchControllerAction.setResponse, response);
    return this;
  }
}
