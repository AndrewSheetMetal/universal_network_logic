import 'package:universal_network_logic/src/error/error.dart';

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

  @override
  String toString() => 'CacheError - ElementNotFound';
}

class UnknownCacheError extends CacheError {
  final dynamic error;

  const UnknownCacheError(this.error);

  @override
  String toString() => 'CacheError - Unknown: $error';
}

class ExpiredCacheError extends CacheError {
  final DateTime expirationDate;

  const ExpiredCacheError(this.expirationDate);

  @override
  String toString() => 'CacheError - Expired';
}
