#((lambda (x) (if (eq x 'nothing-to-see-here) 'move-along 'go-ahead)) 'nothing-to-see-here)

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
