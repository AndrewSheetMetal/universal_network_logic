import 'package:universal_network_logic/error/error.dart';
import 'package:universal_network_logic/model/response_meta_information.dart';

abstract class Response<T> {
  void handleResponse({
    required Function(T data, ResponseMetaInformation metaInformation) onSuccess,
    required Function(RequestError error) onError,
  });

  bool get isSuccess;
  bool get isError;

  SuccessResponse get asSuccessResponse {
    if (this is SuccessResponse) {
      return this as SuccessResponse;
    } else {
      throw Exception("$this is not an Instance of $SuccessResponse. Please check 'isSuccess' before");
    }
  }

  ErrorResponse get asErrorResponse {
    if (this is ErrorResponse) {
      return this as ErrorResponse;
    } else {
      throw Exception("$this is not an Instance of $ErrorResponse. Please check 'isError' before");
    }
  }
}

class SuccessResponse<T> extends Response<T> {
  final T data;

  final ResponseMetaInformation metaInformation;

  SuccessResponse({
    required this.data,
    required this.metaInformation,
  });

  @override
  void handleResponse({
    required Function(T data, ResponseMetaInformation metaInformation) onSuccess,
    required Function(RequestError error) onError,
  }) {
    onSuccess(data, metaInformation);
  }

  @override
  bool get isError => false;

  @override
  bool get isSuccess => true;
}

class ErrorResponse<T> extends Response<T> {
  final RequestError error;

  ErrorResponse(this.error);

  @override
  void handleResponse({
    required Function(T data, ResponseMetaInformation metaInformation) onSuccess,
    required Function(RequestError error) onError,
  }) {
    onError(error);
  }

  @override
  bool get isError => true;

  @override
  bool get isSuccess => false;
}
