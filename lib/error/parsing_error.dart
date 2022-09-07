import 'package:universal_network_logic/error/error.dart';

class ParsingError extends RequestError {
  final String errorMessage;
  final dynamic inputValue;

  ParsingError({
    required this.errorMessage,
    required this.inputValue,
  });

  @override
  String toString() => 'ParsingError(errorMessage: $errorMessage, inputValue: $inputValue)';
}
