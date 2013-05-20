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
- A Grow Only Set (G-Set) has no provision for deleting. It could be implemented with an external locking mechanism and rewriting the set without the deleted index value.
- 

Potential Use Cases:

- Reference all orders belonging to a customer
- Save the users who "liked" something
- Tag content in a Content Management System

Implementation:

CRDT G-Set (Grow only Set)