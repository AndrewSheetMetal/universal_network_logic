///provides additional informations about the Request
abstract class ResponseMetaInformation {
  void handleMetaInformation({
    required Function() onCacheMetaInfo,
    required Function(Duration requestDuration) onNetworkMetaInfo,
  });
}

class CacheMetaInformation extends ResponseMetaInformation {
  @override
  void handleMetaInformation({
    required Function() onCacheMetaInfo,
    required Function(Duration requestDuration) onNetworkMetaInfo,
  }) {
    onCacheMetaInfo();
  }
}

class NetworkMetaInformations extends ResponseMetaInformation {
  final Duration requestDuration;

  NetworkMetaInformations({required this.requestDuration});

  @override
  void handleMetaInformation({
    required Function() onCacheMetaInfo,
    required Function(Duration requestDuration) onNetworkMetaInfo,
  }) {
    onNetworkMetaInfo(requestDuration);
  }

  @override
  String toString() => 'NetworkMetaInformations(requestDuration: $requestDuration)';
}
