Inverted Indexes/Indices for Riak

What is an Inverted Index?

In the context of Riak, an Inverted Index is simply a key which is the term or index value and the value is a list of keys which reference the key values that the term/index value refers to. Inverted Indexes are a viable alterative to Secondary Indexes.

Why use an Inverted Index instead of Riak built in Secondary Indexes or storing a key?

Inverted Index vs Secondary Index

Pros:  

- Inverted Index key lookups are much faster than Secondary Index lookups
- It is potentially much faster to retrieve all the occurences of particular index value if stored in an inverted index
- The extra penalty of index retrieval and modification *may* be less expensive than an 2i index lookup
- Inverted Indexes can be implemented on any backend but Secondary Indexes can only be used with the LevelDB backend.

Cons: 

- There is an additional put for every index term used
- Indexes could potentially grow to very large sizes, necessitating index partitioning which adds to the number of gets and puts for every index modification action
- A Grow Only Set (G-Set) has no provision for deleting. It could be implemented with an external locking mechanism and rewriting the set without the deleted index value.  The properties of an eventually consistent database could still be and issue in the event of a cluster partition.
- In our implemenation, siblings are only merged when an index retrieval operation takes place. Low cardinality in the index key-space results in a potentially large number of siblings between reads which causes an increasingly higher write latency until the silbings are resolved. A well-timed index retrieval will mitigate this issue.
- 2i Binary Indexes allow searching based on part of a 2i value and 2i Integer Indexes allow searching based on a range or 2i Values however Key searching is not possible without the use of Map Reduce jobs.  A viable strategy is to create indexes which point to the terms of other indexes.

Potential Use Cases:

- Reference all orders belonging to a customer
- Save the users who "liked" something
- Tag content in a Content Management System
- Store a Geo Hash of a specific length for fast 

Implementation:

CRDT G-Set (Grow only Set)