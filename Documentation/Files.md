# Files
 
## file

A ValueStore that handles a file. Its Value is Data, so you’ll probably need to use a Codec to encode and decode it to a more manageable value. It accepts a url where the file will be stored, and also a FileManager instance (will use the .default if not specified).

## jsonFile

A ValueStore that handles a file from a Codable value. It relies on the *file* constructor, and adds a jsonCodec on top of it.