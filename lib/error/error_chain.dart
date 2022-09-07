//While trying to make a request it's possible that multiple error occur because the main operation fails and the fallback operation also fails
//e.g. an item is not available in the cache, therefore a network call is made but this also fails
import 'package:network_logic_adapter/error/error.dart';

class ErrorChain extends RequestError {
  final List<RequestError> errors;

  ErrorChain({
    required this.errors,
  });
}
