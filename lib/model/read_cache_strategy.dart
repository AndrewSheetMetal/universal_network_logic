enum ReadCacheStrategy {
  ///try to make the network Call, if it fails, look into the cache
  networkFirst,

  ///look for the cache object first, if the requested item does not exist or is expired, the networkCall is done
  cacheFirst,
}
