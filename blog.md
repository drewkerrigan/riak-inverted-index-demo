Inverted Indexes/Indices for Riak

What is an Inverted Index?

In the context of Riak, an index is a term that you can query on which references other Riak Objects.  Riak already has something called Secondary Indexes but there are some limitations such as requriing

Why use an Inverted Index instead of Riak built in Secondary Indexes or storing a key?

Inverted Index vs Secondary Index (2i)

Pros:  

- Inverted Index key retrievals are faster than Secondary Index lookups.
- It is potentially much faster to retrieve all the occurences of particular index value if stored in an inverted index.
- The extra penalty of index retrieval and modification *may* be less expensive than an 2i index lookup.
- Inverted Indexes can be implemented on any backend, including Bitcask and Memory, but Secondary Indexes can only be used with the LevelDB backend.
- Use of siblings and sibling resolution is accepted as the correct way to handle issues surrounding distributed data storage.  See Aphry's Call Me Maybe (1) series of blog posts for a thorough discussion of issues.
- Since this implemenation of an Inverted Index is built on top of an CRDT (2), the silbing resolution strategy is deterministic and built into the implemenation.
- 2i has overhead which needs to be considered when planning large Riak clusters with more than 512 partitions.
- Ideal for read-heavy applications since Inverted Index retrieval is simply a an additional Riak Get operation.

Cons: 

- Indexes could potentially grow to very large sizes, necessitating index partitioning which adds to implementation complexity and total operation count.
- In this basic implemenation, siblings are only merged when an index retrieval operation takes place. Low cardinality in the index term-space results in a potentially large number of siblings between reads which will cause a high latency when a read does eventually occur.
- 2i Binary Indexes allow searching based on part of a 2i value and 2i Integer Indexes allow searching based on a range or 2i Values however Key searching is not possible without the use of Map Reduce jobs.  A viable strategy is to create indexes which point to the terms of other indexes.  An example would be City_3 (containing the first 3 letters of a City, State combination) index which points to the City index, an index refering the values which have a particular City, State.
- Less ideal for write heavy applications since for each index, and additional put operation is required so to store 1 Riak Object with 3 indexes, a total of 4 puts are required.

Potential Use Cases:

- Reference all orders belonging to a customer
- Save the users who liked something or the things that a user liked.
- Tag content in a Content Management System
- Store a Geo Hash of a specific length for fast geographic lookup/filtering without expensive Geospatial operations
- Reference for time series data where all observations collected within a time-frame are referenced in this particular index.


Implementation:

CRDT G-Set (Grow only Set)


Room for Improvement:

- A Grow Only Set (G-Set) has no provision for deleting. Replacing the G-Set with another CRDT Set such as aObserved-Remove Set (OR-Set) would provide this capability.
- This behavior could be potentially be built into Riak or as an Riak Core application deployed at the nodes to mitigate latency impact of sibling resolution taking place on the Riak Client side.

Demonstration:

Zombies!

The Zombie infestation has taken hold in the United States.  The CDC has collected first 1 million of the casualties and has enlisted your assistance loading the data into their Riak cluster and analyzing the results.

To provide ground teams with fast access to the data we've loaded the data into Riak using Inverted Indexes for both the Zip code and a Geohash


References
