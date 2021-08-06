import 'package:http/http.dart';

typedef HttpRequestCreator<TResponse, TParams>
    = Future<TResponse> Function(TParams params) Function(
        Client client,
        Uri Function(String path, dynamic params) getUri,
        Future<Map<String, String>> Function() getHeaders);

class HttpRemote {
  HttpRemote(
      {required this.client,
      required this.name,
      required this.getUri,
      required this.getHeaders,
      this.onError});

  final String name;
  final Client client;

  final Uri Function(String path, dynamic params) getUri;
  final Future<Map<String, String>> Function() getHeaders;

  final Function(dynamic error)? onError;

  Future<TResponse> Function(TParams) _requestBootstrap<TResponse, TParams>(
      HttpRequestCreator<TResponse, TParams> requestCreator) {
    return (TParams params) async {
      try {
        var request = requestCreator(this.client, this.getUri, this.getHeaders);
        return await request(params);
      } catch (error) {
        if (this.onError != null) {
          this.onError!(error);
        }

        throw error;
      }
    };
  }

  Future<TResponse> Function(TParams) createRequest<TResponse, TParams>(
      HttpRequestCreator<TResponse, TParams> requestCreator) {
    return _requestBootstrap(requestCreator);
  }
}
