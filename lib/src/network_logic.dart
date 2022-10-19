library universal_network_logic;

import 'package:either_dart/either.dart';
import 'package:retry/retry.dart';
import 'package:universal_network_logic/universal_network_logic.dart';

class NetworkLogic {
  final ReadCacheStrategy defaultReadCacheStrategy;
  final RetryOptions? defaultRetryOptions;

  final NetworkError Function(dynamic exception)? defaultNetworkCallExceptionTranslator;

  //if given, the [responseHook] is invoked with every [Response]
  final void Function(Response response)? responseHook;

  NetworkLogic({
    this.defaultRetryOptions,
    this.defaultReadCacheStrategy = ReadCacheStrategy.cacheFirst,
    this.defaultNetworkCallExceptionTranslator,
    this.responseHook,
  });

  Future<Response<T>> readRequest<T>(
    Future<dynamic> Function() networkCall, {
    Future<void> Function(T newValue)? updateCache,
    Future<Either<CacheError, T>> Function()? readFromCache,
    NetworkError Function(dynamic exception)? networkCallExceptionTranslator,
    Either<ParsingError, T> Function(dynamic value)? parserFunction,
    ReadCacheStrategy? cacheStrategy,
    RetryOptions? retryOptions,
  }) async {
    assert(networkCallExceptionTranslator != null || defaultNetworkCallExceptionTranslator != null);

    var request = ReadRequest<T>(
      networkCall,
      networkCallExceptionTranslator: (networkCallExceptionTranslator ?? defaultNetworkCallExceptionTranslator)!,
      updateCache: updateCache,
      readFromCache: readFromCache,
      parserFunction: parserFunction,
      cacheStragegy: cacheStrategy ?? defaultReadCacheStrategy,
      retryOptions: retryOptions ?? defaultRetryOptions,
      responseHook: responseHook,
    );

    return await request();
  }
}
