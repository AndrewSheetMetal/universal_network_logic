import 'package:universal_network_logic/src/error/error.dart';

class NetworkError extends RequestError {
  final dynamic originalException;
  final NetworkErrorType type;

  ///controls whether the network call we retried or not
  ///in cases like Timeouts that makes sense
  ///in other cases like InternalServerErrors it does not make sense
  final bool isRetrySensible;

  const NetworkError({
    required this.type,
    required this.originalException,
    required this.isRetrySensible,
  });

  @override
  String toString() => 'NetworkError(originalException: $originalException, type: $type, isRetrySensible: $isRetrySensible)';
}

enum NetworkErrorType {
  timeout,
  serverError,
  other,
}
