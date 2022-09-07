library network_logic_adapter;

import 'package:either_dart/either.dart';
import 'package:network_logic_adapter/error/cache_error.dart';
import 'package:network_logic_adapter/error/error.dart';
import 'package:network_logic_adapter/error/error_chain.dart';
import 'package:network_logic_adapter/error/network_error.dart';
import 'package:network_logic_adapter/error/parsing_error.dart';
import 'package:network_logic_adapter/model/response.dart';
import 'package:network_logic_adapter/model/response_meta_information.dart';
import 'package:retry/retry.dart';

enum ReadCacheStrategy {
  ///try to make the network Call, if it fails, look into the cache
  networkFirst,

  ///look for the cache object first, if the requested item does not exist or is expired, the networkCall is done
  cacheFirst,
}

class ReadRequest<T extends Object> {
  final Future<dynamic> Function() networkCall;

  ///[updateCache] is invoked, if we get a new valid result from networkCall
  final void Function(T newValue)? updateCache;
  final Future<Either<CacheError, T>> Function()? readFromCache;

  ///if an exception is thrown in networkCall, this function is used to translate it toe
  final NetworkError Function(dynamic exception) networkCallExceptionTranslator;

  final Either<ParsingError, T> Function(dynamic value)? parserFunction;

  //TODO: Seperate Timeout Logic -> in case that networkCall takes to much time

  final ReadCacheStrategy cacheStragegy;

  final RetryOptions? retryOptions;

  ReadRequest(
    this.networkCall, {
    required this.networkCallExceptionTranslator,
    this.parserFunction,
    this.updateCache,
    this.readFromCache,
    this.retryOptions,
    this.cacheStragegy = ReadCacheStrategy.cacheFirst,
  });

  Future<Response<T>> call() async {
    if (cacheStragegy == ReadCacheStrategy.networkFirst || readFromCache == null) {
      var networkCallResult = await _networkCall();
      if (networkCallResult is ErrorResponse && readFromCache != null) {
        try {
          var readFromCacheResult = await readFromCache!();

          if (readFromCacheResult.isLeft) {
            //return both errors to make the error understandable from the outside
            var errorChain = ErrorChain(
              errors: [
                (networkCallResult as ErrorResponse).error,
                readFromCacheResult.left,
              ],
            );

            return ErrorResponse(errorChain);
          } else {
            return SuccessResponse<T>(
              data: readFromCacheResult.right,
              metaInformation:
                  CacheMetaInformation(), //TODO: would be nice to get more informations about the cached object (expiration date and age, but would make readFromCache more complicated)
            );
          }
        } catch (e) {
          //return both errors to make the errors tracable from the outside
          var errorChain = ErrorChain(
            errors: [
              (networkCallResult as ErrorResponse).error,
              CacheError.unknown(e),
            ],
          );

          return ErrorResponse(errorChain);
        }
      } else {
        return networkCallResult;
      }
    } else {
      var result = await readFromCache!();

      if (result.isLeft) {
        return await _networkCall();
      } else {
        return SuccessResponse<T>(
          data: result.right,
          metaInformation: CacheMetaInformation(),
        );
      }
    }
  }

  Future<Response<T>> _networkCall() async {
    if (retryOptions != null) {
      return await _networkCallWithRetryLogic();
    } else {
      return await _networkCallWithoutRetryLogic();
    }
  }

  Future<Response<T>> _networkCallWithRetryLogic() async {
    try {
      //TODO: Adding the numberOfRetries to the MetaInforations would be nice

      return await retryOptions!.retry<Response<T>>(
        () async {
          var result = await _networkCallWithoutRetryLogic();
          if (result is ErrorResponse) {
            //retryIf is only called if an Exception is thrown, therefore, we throw the RequestError here, because _networkCallWithoutRetryLogic() just returns it without throwing
            throw (result as ErrorResponse).error;
          } else {
            return result;
          }
        },
        retryIf: (e) => isRetryableNetworkErrorResponse(e),
      );
    } on RequestError catch (e) {
      //if retryIf fails, or the last retry was made, we have to catch the RequestError here and return it as normal ErrorResponse again
      return ErrorResponse(e);
    }
  }

  static bool isRetryableNetworkErrorResponse(Exception exception) {
    if (exception is NetworkError) {
      return exception.isRetrySensible;
    } else {
      return false;
    }
  }

  Future<Response<T>> _networkCallWithoutRetryLogic() async {
    try {
      var startDateTime = DateTime.now();

      var networkResponse = await networkCall();

      var requestDuration = DateTime.now().difference(startDateTime);

      if (parserFunction == null) {
        if (networkResponse is T) {
          return SuccessResponse<T>(
            data: networkResponse,
            metaInformation: NetworkMetaInformations(requestDuration: requestDuration),
          );
        } else {
          return ErrorResponse(
            ParsingError(
              errorMessage: "'$networkResponse' is not of type $T and no parserFunction is given",
              inputValue: networkResponse,
            ),
          );
        }
      } else {
        try {
          var parsingResult = parserFunction!(networkResponse);

          if (parsingResult.isLeft) {
            return ErrorResponse(parsingResult.left);
          } else {
            updateCache?.call(parsingResult.right);

            return SuccessResponse<T>(
              data: parsingResult.right,
              metaInformation: NetworkMetaInformations(requestDuration: requestDuration),
            );
          }
        } catch (e) {
          return ErrorResponse(
            ParsingError(
              errorMessage: e.toString(),
              inputValue: networkResponse,
            ),
          );
        }
      }
    } catch (e) {
      return ErrorResponse(networkCallExceptionTranslator(e));
    }
  }
}