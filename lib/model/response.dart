import 'package:network_logic_adapter/error/error.dart';
import 'package:network_logic_adapter/model/response_meta_information.dart';

abstract class Response<T> {
  void handleResponse({
    required Function(T data, ResponseMetaInformation metaInformation) onSuccess,
    required Function(RequestError error) onError,
  });
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
}
