import 'package:either_dart/either.dart';
import 'package:fake_async/fake_async.dart';
import 'package:retry/retry.dart';
import 'package:test/test.dart';
import 'package:universial_network_logic/error/cache_error.dart';
import 'package:universial_network_logic/error/error_chain.dart';
import 'package:universial_network_logic/error/network_error.dart';
import 'package:universial_network_logic/error/parsing_error.dart';
import 'package:universial_network_logic/model/response.dart';
import 'package:universial_network_logic/model/response_meta_information.dart';
import 'package:universial_network_logic/read_request.dart';

void main() async {
  group(
    ReadRequest,
    () {
      group(
        'IF networkCall succeeds',
        () {
          group(
            'AND no parserFunction is given',
            () {
              test(
                'IF result of "networkCall" can be converted to T, it will be returned',
                () async {
                  var readRequest = ReadRequest<int>(
                    () async {
                      return 5;
                    },
                    networkCallExceptionTranslator: (e) => NetworkError(
                      type: NetworkErrorType.other,
                      originalException: e,
                      isRetrySensible: false,
                    ),
                  );

                  var result = await readRequest();

                  result.handleResponse(
                    onError: (error) {
                      expect(
                        result,
                        isA<SuccessResponse>(),
                        reason: "Expected SuccessResponse, but got $error",
                      );
                    },
                    onSuccess: (int data, ResponseMetaInformation metaInformation) {
                      expect(data, 5);
                    },
                  );
                },
              );

              test(
                'IF result of "networkCall" can NOT be converted to T, a ParsingError will be returned',
                () async {
                  var readRequest = ReadRequest<int>(
                    () async {
                      return "5"; //returns a String instead of an int
                    },
                    networkCallExceptionTranslator: (e) => NetworkError(
                      type: NetworkErrorType.other,
                      originalException: e,
                      isRetrySensible: false,
                    ),
                  );

                  var result = await readRequest();

                  result.handleResponse(
                    onError: (error) {
                      expect(
                        error,
                        isA<ParsingError>(),
                        reason: "Expected ParsingError, but got $error",
                      );
                    },
                    onSuccess: (int data, ResponseMetaInformation metaInformation) {
                      expect(
                        result,
                        isA<ErrorResponse>(),
                        reason: "Expected ErrorResponse, but got $result",
                      );
                    },
                  );
                },
              );
            },
          );

          group(
            'AND a parserFunction is given',
            () {
              test(
                'IF parserFunction succeeds THEN the result of parserFunction will be returned',
                () async {
                  var readRequest = ReadRequest<int>(
                    () async {
                      return 1;
                    },
                    networkCallExceptionTranslator: (e) => NetworkError(
                      type: NetworkErrorType.other,
                      originalException: e,
                      isRetrySensible: false,
                    ),
                    parserFunction: (value) => const Right(2),
                  );

                  var result = await readRequest();

                  result.handleResponse(
                    onError: (error) {
                      expect(
                        result,
                        isA<SuccessResponse>(),
                        reason: "Expected SuccessResponse, but got $result",
                      );
                    },
                    onSuccess: (int data, ResponseMetaInformation metaInformation) {
                      expect(
                        data,
                        2,
                        reason: "Expected '2' because its the result of the parserFunction",
                      );
                    },
                  );
                },
              );

              test(
                'IF parserFunction returns ParsingError THEN an ErrorResponse with the ParsingError is returned',
                () async {
                  var readRequest = ReadRequest<int>(
                    () async {
                      return 1;
                    },
                    networkCallExceptionTranslator: (e) => NetworkError(
                      type: NetworkErrorType.other,
                      originalException: e,
                      isRetrySensible: false,
                    ),
                    parserFunction: (value) => Left(
                      ParsingError(
                        errorMessage: "",
                        inputValue: value,
                      ),
                    ),
                  );

                  var result = await readRequest();

                  result.handleResponse(
                    onError: (error) {
                      expect(
                        error,
                        isA<ParsingError>(),
                        reason: "Expected ParsingError, but got $error",
                      );
                    },
                    onSuccess: (int data, ResponseMetaInformation metaInformation) {
                      expect(
                        result,
                        isA<ErrorResponse>(),
                        reason: "Expected ErrorResponse, but got $result",
                      );
                    },
                  );
                },
              );

              test(
                'IF exception in parserFunction occurs THEN an ErrorResponse with the ParsingError is returned',
                () async {
                  var readRequest = ReadRequest<int>(
                    () async {
                      return 1;
                    },
                    networkCallExceptionTranslator: (e) => NetworkError(
                      type: NetworkErrorType.other,
                      originalException: e,
                      isRetrySensible: false,
                    ),
                    parserFunction: (value) {
                      throw Exception("Some Exception in parserFunction");
                    },
                  );

                  var result = await readRequest();

                  result.handleResponse(
                    onError: (error) {
                      expect(
                        error,
                        isA<ParsingError>(),
                        reason: "Expected ParsingError, but got $error",
                      );
                    },
                    onSuccess: (int data, ResponseMetaInformation metaInformation) {
                      expect(
                        result,
                        isA<ErrorResponse>(),
                        reason: "Expected ErrorResponse, but got $result",
                      );
                    },
                  );
                },
              );
            },
          );

          group(
            'ResponseMetaInformation',
            () {
              test(
                'contains the requestDuration as the time that networkCall needed',
                () async {
                  fakeAsync((asyncFaker) async {
                    var readRequest = ReadRequest<int>(
                      () async {
                        asyncFaker.elapse(const Duration(milliseconds: 400));

                        return 5;
                      },
                      networkCallExceptionTranslator: (e) => NetworkError(
                        type: NetworkErrorType.other,
                        originalException: e,
                        isRetrySensible: false,
                      ),
                    );

                    var result = await readRequest();

                    result.handleResponse(
                      onError: (error) {
                        expect(
                          result,
                          isA<SuccessResponse>(),
                          reason: "Expected SuccessResponse, but got $error",
                        );
                      },
                      onSuccess: (int data, ResponseMetaInformation metaInformation) {
                        expect(metaInformation, isA<NetworkMetaInformations>());

                        expect(
                          (metaInformation as NetworkMetaInformations).requestDuration,
                          const Duration(milliseconds: 400),
                          reason: "requestDuration should be the time that networkCall needed",
                        );
                      },
                    );
                  });
                },
              );
            },
          );
        },
      );

      group(
        'IF networkCall throws an Exception',
        () {
          test(
            'AND neither readFromCache nor retry logic is given THEN an ErrorResponse is returned',
            () async {
              var readRequest = ReadRequest<int>(
                () async {
                  throw Exception("My Exception");
                },
                networkCallExceptionTranslator: (e) => NetworkError(
                  type: NetworkErrorType.other,
                  originalException: e,
                  isRetrySensible: false,
                ),
              );

              var result = await readRequest();

              expect(result, isA<ErrorResponse>());

              expect(
                (result as ErrorResponse).error,
                isA<NetworkError>().having(
                  (error) => error.type,
                  "Type of Error should be 'other'",
                  equals(NetworkErrorType.other),
                ),
              );
            },
          );

          group(
            'AND readFromCache is given',
            () {
              test(
                'IF readFromCache succeeds, the result of the Cache is returned',
                () async {
                  var readRequest = ReadRequest<int>(
                    () async {
                      throw Exception("My Exception");
                    },
                    networkCallExceptionTranslator: (e) => NetworkError(
                      type: NetworkErrorType.other,
                      originalException: e,
                      isRetrySensible: false,
                    ),
                    cacheStragegy: ReadCacheStrategy.networkFirst,
                    readFromCache: () async {
                      return const Right(5);
                    },
                  );

                  var result = await readRequest();

                  expect(result, isA<SuccessResponse>());

                  expect(
                    result,
                    isA<SuccessResponse>()
                        .having(
                          (response) => response.data,
                          "data should be '5', as returned by readFromCache",
                          equals(5),
                        )
                        .having(
                          (response) => response.metaInformation,
                          "meta information should be a CacheMetaInformation",
                          isA<CacheMetaInformation>(),
                        ),
                  );
                },
              );

              test(
                'IF readFromCache returns CacheError THEN an ErrorChain with both errors is returned',
                () async {
                  var readRequest = ReadRequest<int>(
                    () async {
                      throw Exception("My Exception");
                    },
                    networkCallExceptionTranslator: (e) => NetworkError(
                      type: NetworkErrorType.other,
                      originalException: e,
                      isRetrySensible: false,
                    ),
                    cacheStragegy: ReadCacheStrategy.networkFirst,
                    readFromCache: () async {
                      return Left(CacheError.elementNotFound());
                    },
                  );

                  var result = await readRequest();

                  expect(
                    result,
                    isA<ErrorResponse>().having(
                      (response) => response.error,
                      "ErrorResponse should contain an ErrorChain",
                      isA<ErrorChain>()
                          .having(
                            (errorChain) => errorChain.errors.length,
                            "Expected 2 errors in ErrorChain",
                            equals(2),
                          )
                          .having(
                            (errorChain) => errorChain.errors.first,
                            "First Error should be the NetworkError",
                            isA<NetworkError>(),
                          )
                          .having(
                            (errorChain) => errorChain.errors.last,
                            "First Error should be the ElementNotFoundCacheError",
                            isA<ElementNotFoundCacheError>(),
                          ),
                    ),
                    reason: "Should be an Error Response with an ErrorChain",
                  );
                },
              );

              test(
                'IF readFromCache throws Exception THEN an ErrorChain with both errors is returned',
                () async {
                  var readRequest = ReadRequest<int>(
                    () async {
                      throw Exception("My Exception");
                    },
                    networkCallExceptionTranslator: (e) => NetworkError(
                      type: NetworkErrorType.other,
                      originalException: e,
                      isRetrySensible: false,
                    ),
                    cacheStragegy: ReadCacheStrategy.networkFirst,
                    readFromCache: () async {
                      throw Exception("readFromCache Exception");
                    },
                  );

                  var result = await readRequest();

                  expect(
                    result,
                    isA<ErrorResponse>().having(
                      (response) => response.error,
                      "ErrorResponse should contain an ErrorChain",
                      isA<ErrorChain>()
                          .having(
                            (errorChain) => errorChain.errors.length,
                            "Expected 2 errors in ErrorChain",
                            equals(2),
                          )
                          .having(
                            (errorChain) => errorChain.errors.first,
                            "First Error should be the NetworkError",
                            isA<NetworkError>(),
                          )
                          .having(
                            (errorChain) => errorChain.errors.last,
                            "First Error should be the UnknownCacheError",
                            isA<UnknownCacheError>(),
                          ),
                    ),
                    reason: "Should be an Error Response with an ErrorChain",
                  );
                },
              );
            },
          );
        },
      );

      group(
        'IF ReadCacheStrategy is "cacheFirst"',
        () {
          test(
            'IF readFromCache returns data THEN this data is returned',
            () async {},
          );

          test(
            'IF readFromCache throws Exception THEN networkCall() is invoked',
            () async {},
          );

          test(
            'IF readFromCache returns CacheError THEN networkCall() is invoked',
            () async {},
          );
        },
      );

      group(
        'IF retryOptions are given',
        () {
          group(
            'AND the Exception thrown in networkCall is translated to a retryable NetworkError THEN the networkCall is called multiple times',
            () {
              test(
                'AND returns the first result that is not an Exception',
                () async {
                  var i = 0;

                  var readRequest = ReadRequest<int>(
                    () async {
                      if (i < 5) {
                        i++;
                        throw Exception("My Exception: $i");
                      } else {
                        return i;
                      }
                    },
                    parserFunction: ,
                    networkCallExceptionTranslator: (e) => NetworkError(
                      type: NetworkErrorType.other,
                      originalException: e,
                      isRetrySensible: true, //<- true here!
                    ),
                    cacheStragegy: ReadCacheStrategy.networkFirst,
                    retryOptions: const RetryOptions(
                      maxAttempts: 8,
                      maxDelay: Duration(milliseconds: 10),
                    ),
                  );

                  var result = await readRequest();

                  expect(
                    result,
                    isA<SuccessResponse>().having(
                      (response) => response.data,
                      "data should be 5",
                      5,
                    ),
                    reason: "The request should work after 5 retries, but got $result",
                  );
                },
              );

              test(
                'AND returns the last NetworkError that is thrown',
                () async {
                  var i = 0;

                  const maxAttempts = 8;

                  var readRequest = ReadRequest<int>(
                    () async {
                      i++;
                      throw i; //always throw an Error
                    },
                    networkCallExceptionTranslator: (e) => NetworkError(
                      type: NetworkErrorType.other,
                      originalException: e,
                      isRetrySensible: true, //<- true here!
                    ),
                    cacheStragegy: ReadCacheStrategy.networkFirst,
                    retryOptions: const RetryOptions(
                      maxAttempts: maxAttempts,
                      maxDelay: Duration(milliseconds: 10),
                    ),
                  );

                  var result = await readRequest();

                  expect(
                    result,
                    isA<ErrorResponse>().having(
                      (response) => response.error,
                      "expected error to be NetworkError",
                      isA<NetworkError>().having(
                        (error) => error.originalException,
                        "the network error should contain the error message from the last retry call. Here: the number of maxAttempts ($maxAttempts)",
                        maxAttempts,
                      ),
                    ),
                    reason: "The request should return the last thrown NetworkError",
                  );
                },
              );
            },
          );

          test(
            'AND the Exception thrown in networkCall is NOT translated to a retryable NetworkError THEN the Error from networkCall will be returned',
            () async {
              var i = 0;

              var readRequest = ReadRequest<int>(
                () async {
                  i++;
                  throw i;
                },
                networkCallExceptionTranslator: (e) => NetworkError(
                  type: NetworkErrorType.other,
                  originalException: e,
                  isRetrySensible: false, //<- false here!
                ),
                cacheStragegy: ReadCacheStrategy.networkFirst,
                retryOptions: const RetryOptions(
                  maxDelay: Duration(milliseconds: 10),
                ),
              );

              var result = await readRequest();

              expect(
                i,
                1,
                reason: "the network call should have only called once",
              );

              expect(
                result,
                isA<ErrorResponse>().having(
                  (response) => response.error,
                  "expected error to be NetworkError",
                  isA<NetworkError>().having(
                    (error) => error.originalException,
                    "with the exception from the one and only networkCall",
                    1,
                  ),
                ),
                reason: "The request should return the last thrown NetworkError",
              );
            },
          );
        },
      );
    },
  );
}
