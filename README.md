# Depenency Resolver (POC)

Given a list of dependencies, it will walk the tree and return an ordered list of depenencies which if executed in order should provide proper resolution.

## Purpose

The initial trigger for this was to be able to identify in what order database depenencies need to be loded in what order.  When there are thousands of items, a machine needs to determine how items are related and in what order they need to be loaded.

## References

This is the blog post used to get started: [dependency-resolving-algorithm](https://www.electricmonk.nl/log/2008/08/07/dependency-resolving-algorithm/)

A simple SO showing how to retrieve depenencies from SQL Server: [how-to-find-all-the-dependencies-of-a-table-in-sql-server](https://stackoverflow.com/questions/22005698/how-to-find-all-the-dependencies-of-a-table-in-sql-server)

A SO showing how to address cross database dependencies: [Cross database dependancies](https://stackoverflow.com/questions/13757387/getting-sql-server-cross-database-dependencies)


## Objectives

NOTE: **The following is still a work in progress**

Can we take an existing, complex database schema, identify relationships between entities, and identify the tasks that need to be run to build the database from the ground up.

In this case a database is a graph. So lets understand graphs before beginning.

### Edges and Nodes
[This article helps us understand](https://wiki.haskell.org/99_questions/80_to_89), each entity we need to add is a node and each relationship is an edge. We will need a directed graph to represent a node having a 'directed' relationship with another node, meaning one entity will rely on another node in some way.

### Directed Acyclic Graph
[This article helps us understand](https://en.wikipedia.org/wiki/Directed_acyclic_graph) we not only need a directed graph(where edges have a direction) but more specifically a directed **acyclic** graph(DAG), where acyclic means not having cycles or loops. 

### Topological sort

Once we have a DAG we can do a [Topological Sort](https://en.wikipedia.org/wiki/Topological_sorting) which is "a sequence of the vertices[nodes] such that every edge is directed from earlier to later in the sequence". This is the order in which entities need to be created.




## Deriving a DAG

Once we have a DAG, we can derive a topological sort, **but** we may not be given a DAG. So, if we start with a directed graph how to we derive a DAG from it?

### Simplifying a graph

Graphs can be simplified by either removing their edges or nodes. [Transitive Reduction](https://en.wikipedia.org/wiki/Transitive_reduction) is a way to remove edges but preserve paths.

> In a finite graph that may have cycles, the transitive reduction is not unique: there may be more than one graph on the same vertex set that has a minimum number of edges and has the same reachability relation as the given graph.

Terminology:
[Uniqueness](https://en.wikipedia.org/wiki/Topological_sorting#Uniqueness)
> If a topological sort has the property that all pairs of consecutive vertices in the sorted order are connected by edges, then these edges form a directed Hamiltonian path in the DAG. If a Hamiltonian path exists, the topological sort order is unique; no other order respects the edges of the path. Conversely, if a topological sort does not form a Hamiltonian path, the DAG will have two or more valid topological orderings, for in this case it is always possible to form a second valid ordering by swapping two consecutive vertices that are not connected by an edge to each other.

### Transitive Reduction Algos

[Graphviz](https://emden.github.io/documentation/) is a tool to render pretty looking graphs. It also has tool built in to work with graphs. One tool is called [tred](https://emden.github.io/_pages/pdf/tred.1.pdf), short for transitive reduction, that helps reduce the edges in a graph.

It can be used by installing Graphviz, then running `tred` on the command line, including as the first parameter the name of the file containing the graph description. The graph is described in [Dot language](https://emden.github.io/_pages/doc/info/lang.html). Examples of the language can be seen below.

#### Example 1
```
digraph {
  A -> B;
  B -> C;
  A -> C;
}
```

**Output**

```
digraph {
	A -> B;
	B -> C;
}
```

#### Example 2
contains a cycle

```
  1  ----|--> 2
  ∆      V    V
  3  <-  4 -> 5
```

```
digraph {
  1 -> 2
  1 -> 4
  2 -> 5
  4 -> 5
  3 -> 1
  4 -> 3
}
```

**Output**

The connection from `4 -> 5` was removed, but the cycle `1 -> 4 -> 3 -> 1` cannot be removed.

```
  1  ----|--> 2
  Λ      V    V
  3  <-  4    5
```

```
warning: %1 has cycle(s), transitive reduction not unique
cycle involves edge 3 -> 1
digraph {
	1 -> 2;
	1 -> 4;
	2 -> 5;
	4 -> 3;
	3 -> 1;
}
```

### Removing Cycles

How can we remove cycles to get our graph to be a DAG?

**But**, transitive reduction does not neccesarily remove cycles.

It is possible to transform a graph with cycles into a DAG:

> Transforming a directed graph with cycles into a DAG by deleting as few vertices or edges as possible (the feedback vertex set and feedback edge set problem, respectively) is NP-hard, but any directed graph can be made into a DAG (its condensation) by contracting each strongly connected component into a single supervertex. The problems of finding shortest paths and longest paths can be solved on DAGs in linear time, in contrast to arbitrary graphs for which shortest path algorithms are slower and longest path problems are NP-hard.
-[Transitive Reduction](https://en.wikipedia.org/wiki/Transitive_reduction)

### DAG to Topological sort

Can we determine if a graph can be a DAG?

There are algorithms that do topological sorting
https://gist.github.com/msanatan/7933189
> This algorithm can only work on Directed Acyclic Graphs. In this variation we do not save the nodes in an order, but if we cannot remove all nodes from the graph then a topological sort isn't possible implying the graph has a cycle.

### Topological Sort with Graphiz

Graphviz contains a graph editor called [gvpr](https://graphviz.gitlab.io/_pages/pdf/gvpr.1.pdf). With it and a basic program we can do a [Topological sort in Graphviz's gvpr](https://gist.github.com/hilverd/3343995)

Command:
```
gvpr -f src/tsort.g src/graph.g
```

The quality of this code is unknown.

### Preventing Cycles in Code

While traversing a graph, you may not want to visit already visited nodes. To do this, you can pass the graph and a structure to track if a node has been visited
https://stackoverflow.com/questions/21074766/traversing-a-graph-breadth-first-marking-visited-nodes-in-haskell

[Another way is to use a stack](https://codereview.stackexchange.com/questions/90954/detecting-cycles-in-a-directed-graph-without-using-mutable-sets-of-nodes)
> This implementation makes use of a stack to track nodes currently being visited and an extra set of nodes which have already been explored.


## Other Notes

A conversation about this:

```
<emilypi> 
https://en.wikipedia.org/wiki/Arborescence_%28graph_theory%29
??
I imagine you'd take the spanning tree of the graph, but directed spanning trees are a hard problem
NP-hard, iirc http://www.cs.tau.ac.il/~zwick/grad-algo-13/directed-mst.pdf
There's an algorithm called "edmond's algorithm" for finding it https://en.wikipedia.org/wiki/Edmonds%27_algorithm


<gregberns>
ha yea there is a lot out there, I'd like to try and find an algo already written. found this but havent looked at it too deeply https://networkx.github.io/documentation/latest/reference/algorithms/generated/networkx.algorithms.dag.transitive_reduction.html
not sure I have the time to get a phd before I solve the problem
this stuff is super cool though

<gregberns>
emilypi: from what you sent over, an arboresence is a 'path' through a graph which is a DAG. So with several arboresences you could build the original graph. Interesting. Seems like spanning trees are just directed arboresences. The Edmunds algo looks quite interesting and seems to emphasize weights on the edges. 
4:36 PM So heres the problem I'm trying to solve, I have a database with a ton of stored procs and functions, but they are connected in a web of dependencies on each other. I need to figure out the order in which to create each one. So if theres `a>b; b>c; a>c` the install order needs to be `a b c`. 
4:36 PM One problem I see, even if there was a set of arboresence's that covered all the the items needed, I suspect there would still be dependency issues with items not existing (if `a>c; b>c; c>d`, and I run the `a>c>d` tree, c will fail because b is a dependency). And I cant think of how the edges would have weights  (for Edmunds)

<emilypi> 
Not quite - an arborescence is a directed graph such that for a fixed root, you have 1 and only 1 path to every other vertex. In other words, a directed ST will be -an- arborescence for a directed graph. Both will be necessarily acyclic. The problem Edmond's tries to solve is the -least- arborescent ST of a given graph (i.e. solves the optimal branching problem). I'm not sure if it's applicable, but it sounds similar
```
