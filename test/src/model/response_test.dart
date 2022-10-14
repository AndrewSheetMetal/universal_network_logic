import 'package:test/test.dart';
import 'package:universal_network_logic/src/model/response.dart';
import 'package:universal_network_logic/universal_network_logic.dart';

void main() {
  group(
    Response,
    () {
      group(
        SuccessResponse,
        () {
          test(
            'copyWithData returns a new SuccessResponse with the same MetaInformations',
            () async {
              var original = SuccessResponse<int>(
                data: 5,
                metaInformation: NetworkMetaInformations(
                  requestDuration: const Duration(milliseconds: 123),
                ),
              );

              var copy = original.copyWithData<String>(data: "5");

              expect(copy.data, "5");
              expect(
                copy.metaInformation,
                isA<NetworkMetaInformations>().having(
                  (p0) => p0.requestDuration,
                  "Having the same MetaInformations",
                  const Duration(milliseconds: 123),
                ),
              );
            },
          );
        },
      );
    },
  );
}
