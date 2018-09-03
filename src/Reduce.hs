module Reduce where

-- https://graphviz.gitlab.io/_pages/doc/info/lang.html
-- graph	:	[ strict ] (graph | digraph) [ ID ] '{' stmt_list '}'
-- stmt_list	:	[ stmt [ ';' ] stmt_list ]
-- stmt	:	node_stmt
-- |	edge_stmt
-- |	attr_stmt
-- |	ID '=' ID
-- |	subgraph
-- attr_stmt	:	(graph | node | edge) attr_list
-- attr_list	:	'[' [ a_list ] ']' [ attr_list ]
-- a_list	:	ID '=' ID [ (';' | ',') ] [ a_list ]
-- edge_stmt	:	(node_id | subgraph) edgeRHS [ attr_list ]
-- edgeRHS	:	edgeop (node_id | subgraph) [ edgeRHS ]
-- node_stmt	:	node_id [ attr_list ]
-- node_id	:	ID [ port ]
-- port	:	':' ID [ ':' compass_pt ]
-- |	':' compass_pt
-- subgraph	:	[ subgraph [ ID ] ] '{' stmt_list '}'
-- compass_pt	:	(n | ne | e | se | s | sw | w | nw | c | _)
-- An edgeop is -> in directed graphs and -- in undirected graphs.