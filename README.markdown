#((lambda (x) (if (eq x 'nothing-to-see-here) 'move-along 'go-ahead)) 'nothing-to-see-here)

##JMC

Yes, another aborted lisp. This one based on Paul Graham's essay: 
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

Or something like that.

A scheme implementation of the same LISP (McCarthy's lisp) is also provided, although it was never tested.

##Norvig

This one, a Scheme interpreter, is inspired by Peter Norvig's [lispy](http://norvig.com/lispy.html) and the tests (and hopefully completion) is taken from [lispy2](http://norvig.com/lispy2.html). 

It greatly differs from the latter in that it doesn't represent _everything_ as an array in the environment, but instead uses ruby Objects. Also, the environment is preloaded with lots of math functions and some lisp functions you'd expect in scheme. 

This one does have a REPL, just run `ruby norvig.rb` and have fun.
