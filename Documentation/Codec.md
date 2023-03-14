#  Codec

A codec is an interface that represents a conversion between two different types that can fail in both directions.

## Constructors

You can construct a Codec by passing two throwing functions that convert an Input into an Output and an viceversa.

### error

A Codec that will always fail. Useful for tests and debug purposes.

### json

Transform a Codable value into Data and parse Data into a Codable value.

### jsonCodec

Same as #json#, but allows to specify the JSONDecoder and JSONEncoder instead of using the default ones.

### utf8

Conversion between String and Data, using utf8 encoding.

### url

Conversion between URL and String. Uses absoluteString in one direction and tries to create a URL from a string in the other one.

### representing

Conversion between a RawRepresentable and its RawValue.

## Utilities

### mapError

This function allows to capture and transform them. It returns a Codec that will produce the transformed errors instead of the original ones.

 

