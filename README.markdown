# A tale of at least two lisps

Many moons ago as a wide-eyed neophyte, I discovered Lisp. Only a year or so before, during my senior year in college, I spent three months writing a [compiler for a subset of Ada 95 in Java](https://github.com/lfborjas/micro_ada) for my compilers class. It was a fascinating adventure involving many thousands of lines of code and black magic incantations I wasn't 100% sure about, and in the end, I was able to feed unsuspecting ADA files to a Java GUI and get assembly code executed in a micro set of instructions. When I read articles about Lisp, I couldn't believe that an interpreted language with almost no syntax and even older than ADA 95 could be as or even more powerful than my rickety facsimile of a compiler when fed through a minimalist interpreted that could fit in a reasonably sized source file in ruby or python. Furthermore, I couldn't fathom that one could write said interpreter in the _same_ language that was to be interpreted. Needles to say, I got excited.

Back when I wrote this in 2011, it seemed like a good idea to have each of my forays into this metalinguistic adventure in separate git branches, choosing my Ruby one as the default branch due to some vague inkling that it shared the spirit of Lisp amongst its abundance of syntax. The rest of the README covers the general motivations of my two Ruby programs approaching a Lisp interpreter from the Paul Graham and Peter Norvig camps, but I'd urge you to read all of my naïve implemenatations, left untarnished by my future self apart from this README overture:

* The Paul Graham approach, [in Clojure](https://github.com/lfborjas/minimalisp/blob/clojure/src/jmc_lisp/core.clj) -- I even wrote [tests](https://github.com/lfborjas/minimalisp/blob/clojure/test/jmc_lisp/test/core.clj) (!)
* The Peter Norvig sentiment, [in Javascript](https://github.com/lfborjas/minimalisp/blob/javascript/scheme.js) -- there's a little REPL in there.
* Three different flavors, one with bad macros, [in Scheme](https://github.com/lfborjas/minimalisp/tree/scheme)
* Bonus content: a little [presentation](http://tech.lfborjas.com/minimalisp/index.html) I gave in Spanish a few times, and an [English version](http://tech.lfborjas.com/talks/bbox_ebb/index.html) I prepared many years after, to give at work.

## JMC's Lisp, according to Paul Graham

This one based on Paul Graham's essay: 
["The roots of lisp"](http://www.paulgraham.com/rootsoflisp.html)
Wrote it and uploaded here

Instead of using classes and nice stuff, I just screwed up the `Object`class to have
unholy methods like `car`, `caddr`, `cdr` (any cxr, actually) and `_eval`.

As any mathematical thingy, it assumes you provide nice inputs (it goes into a satanic
infinite loop of recursion if not).

I did this in an afternoon and didn't even write a parser, but you can use it like this:

    [[lambda,
        [:x],
            [:cond,
              [[:eq, :x, [:quote, :nothing-to-see-here]], :move-along]
              [:t, [:quote, :go-ahead]]]]
      [:quote, :nothing-to-see-here]]._eval([
        #you'd put the environment here...
      ])

Or something like that. There's tests though!

A scheme implementation of the same LISP (McCarthy's lisp) is also provided, although it was never tested.

## Norvig's Scheme interpreter in Python, a Ruby response.

This one, a Scheme interpreter, is inspired by Peter Norvig's [lispy](http://norvig.com/lispy.html) and the tests (and hopefully completion) is taken from [lispy2](http://norvig.com/lispy2.html). 

It greatly differs from the latter in that it doesn't represent _everything_ as an array in the environment, but instead uses ruby Objects. Also, the environment is preloaded with lots of math functions and some lisp functions you'd expect in scheme. 

This one does have a REPL, just run `ruby norvig.rb` and have fun.
