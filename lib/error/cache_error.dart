import 'package:universial_network_logic/error/error.dart';

abstract class CacheError extends RequestError {
  const CacheError();

  factory CacheError.unknown(dynamic error) {
    return UnknownCacheError(error);
  }

  factory CacheError.expired(DateTime expirationDate) {
    return ExpiredCacheError(expirationDate);
  }

  factory CacheError.elementNotFound() {
    return const ElementNotFoundCacheError();
  }
}

class ElementNotFoundCacheError extends CacheError {
  const ElementNotFoundCacheError();
}

class UnknownCacheError extends CacheError {
  final dynamic error;

  const UnknownCacheError(this.error);
}

class ExpiredCacheError extends CacheError {
  final DateTime expirationDate;

  const ExpiredCacheError(this.expirationDate);
}
