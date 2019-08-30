
NOTE: Some very rought ideas below.

How can we identify non-referentially transparent expressions and statements in a language?
(Sounds very hard ... :( )
build a tree, when a method is called check it (how do we find the method) for ref-trans.
We would need to know what the method is being passed, which would require types.
Also if the thing called is a function passed through as a parameter, we can't know whether that is ref-trans.



Course on Type systems
http://pauillac.inria.fr/~remy/mpri/2016/cours.pdf


```
add (a: int|string) (b: int|string) = a + b
```

More accutately
```
add ((a: string) (b: string) | (a: int) (b: int)) = a + b
```

Do a lookup on `+` to see what types it contains

It would have `binOp int int | binOp string string` 

Youd want to start with a local context and step up into parent contexts, finishing with a global context that would contain `+`


Could we create a JS syntax sitting on top of the Haskell AST?

```
a ∶∶= x ∣ λx. a ∣ a a 
```

This definition says that an expression a is a variable x, an abstraction λx. a, or an application a1 a2.

Could we turn statement bodies (List of Statement) into an expression? Probably yes.

```
let a = 1;
let b = a + 2;
return b;
```

```
\a.\b.a+2 (1)


(flip (=<<)) (1) (\a ->
  (flip (=<<)) (a + 2) (\b ->
    b
  ))

let id x = x
\a.a + 2 \b -> b (id 1)
```

> Encode side effects as values

Array.push [] newValue 


https://livebook.manning.com/#!/book/get-programming-with-haskell/chapter-42/6


Haskell Effects
https://www.doc.ic.ac.uk/~dorchard/publ/haskell14-effects.pdf

  

```
type var = string
type term =
| Var of var
| Fun of var ∗ term
| App of term ∗ term


(f => f(f)) (x => x)
(x => x) x
x

let h = PApp (PFun (fun f → PApp (PVar f, PVar f)), PFun (fun x → PVar x))
(\f. f f) (\x.x)
(\x.x) (\x.x)
(\x.x)
x

```


