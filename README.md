<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

Universial Network Logic provides the skeleton for network calls, caching, parsing and retry logic

## Features

ReadRequests:
* writing to cache, if the network call succeeds
* reading from cache
* retry logic
* meta informations for successful network calls
  * elapsed time for the network call


TODO: Other kinds of requests

## Usage

```dart
var readRequest = ReadRequest<T>(
    () async {
        //any network call you want to make
    },
    networkCallExceptionTranslator: (e) {
        //if the network call throws an exception, this method will be called
        //it must return a `NetworkError`
        
        //`NetworkError` has a special member `isRetrySensible` if it is true, 
        //the network call will be retried if `retryOptions` are provided
    }
    updateCache: (T element) {
        //(optional)
        //write the parsed element (here 5) to your own caching logic
    }
    readFromCache: () async {
        //(optional)
        //depending on the caching strategy 

        return Left(CacheError.elementNotFound());
    },
    cacheStragegy: ReadCacheStrategy.networkFirst, //decides whether the data is first tried to be fetched from network or from cache. If the first way fails, the other way is used
    retryOptions: const RetryOptions( //(optional)
        maxAttempts: 8,
    ),
    parserFunction: (rawNetworkData) {
        //(optional)
        //the result of the network call will be provided to this function.
        //based on you own logic you can return a value of type T
        //or a ParsingError can be returned

        //if the parserFunction is not given, it's check if the original return value of the network call has the generic type T. 
        //if thats the case, it is returned
        //otherwise a ParsingError is returned
    }
);

var result = await readRequest();
```

## Additional information

### Architecture Considerations

#### Usage of Either<L,R> instead of Exceptions

Using Either<L,R> instead of throwing Exceptions has the advantage, that it is much harder to forget to handle the exception cases.
On the other hand, the direct caller must deal with it, you can not just define a global try catch.


