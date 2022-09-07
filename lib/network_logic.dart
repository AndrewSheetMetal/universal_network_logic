library universial_network_logic;

import 'package:either_dart/either.dart';
import 'package:retry/retry.dart';
import 'package:universial_network_logic/error/cache_error.dart';
import 'package:universial_network_logic/error/network_error.dart';
import 'package:universial_network_logic/error/parsing_error.dart';
import 'package:universial_network_logic/model/read_cache_strategy.dart';
import 'package:universial_network_logic/model/response.dart';
import 'package:universial_network_logic/read_request.dart';

class NetworkLogic {
  final ReadCacheStrategy defaultReadCacheStrategy;
  final RetryOptions? defaultRetryOptions;

  final NetworkError Function(dynamic exception)? defaultNetworkCallExceptionTranslator;

  NetworkLogic({
    this.defaultRetryOptions,
    this.defaultReadCacheStrategy = ReadCacheStrategy.cacheFirst,
    this.defaultNetworkCallExceptionTranslator,
  });

  Future<Response<T>> readRequest<T>(
    Future<dynamic> Function() networkCall,
    Future<void> Function(T newValue)? updateCache,
    Future<Either<CacheError, T>> Function()? readFromCache,
    NetworkError Function(dynamic exception)? networkCallExceptionTranslator,
    Either<ParsingError, T> Function(dynamic value)? parserFunction,
    ReadCacheStrategy? cacheStrategy,
    RetryOptions? retryOptions,
  ) async {
    assert(networkCallExceptionTranslator != null || defaultNetworkCallExceptionTranslator != null);

    var request = ReadRequest<T>(
      networkCall,
      networkCallExceptionTranslator: (networkCallExceptionTranslator ?? defaultNetworkCallExceptionTranslator)!,
      updateCache: updateCache,
      readFromCache: readFromCache,
      parserFunction: parserFunction,
      cacheStragegy: cacheStrategy ?? defaultReadCacheStrategy,
      retryOptions: retryOptions ?? defaultRetryOptions,
    );

    return await request();
  }
}
