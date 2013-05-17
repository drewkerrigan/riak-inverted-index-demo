Inverted Indexes/Indices for Riak

What is an Inverted Index?

Why use an Inverted Index instead of Riak built in Secondary Indexes or storing a key?

Inverted Index vs Secondary Index

Pros:  

- Secondary Index lookups are more expensive than key lookups
- It is potentially much faster to retrieve all the occurences of particular index value if stored in an inverted index
- The extra penalty of index retrieval and modification *may* be less expensive than an 2i index lookup

Cons: 

- Adding an index value for a key involves a get and a put for the index on the Riak Side
- Indexes could potentially grow to very large sizes, necessitating index partitioning which adds to the number of gets and puts for every index modification action

Implemenatation:

CRDT G-Set (Grow only Set)