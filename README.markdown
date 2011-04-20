#Barcamp 4: Lisp

Este es el código fuente de mi presentación sobre lisp. 
El código de la implementación en sí está [acá](https://github.com/lfborjas/minimalisp/tree/clojure), 
La presentación está hecha usando [mi propia versión de showoff](https://github.com/lfborjas/showoff), 
una librería de [ruby](http://www.ruby-lang.org/en/) que sirve para hacer presentaciones decentes
desde un simple editor de texto y una terminal.

Si querés probarla, instalá ruby y luego instalá showoff con `sudo gem install showoff` (si querés
instalar mi versión, que usa [pygments](http://pygments.org/) para el coloreo de sintaxis, tendrás que tener python
también e instalar pygments con `sudo apt-get install python-setuptools && easy_install pygments`)
Una vez instalado showoff, sólo corrés `showoff serve` para verla en tu browser o `showoff static`
para generar html que te podés robar y poner en tu propia página.

##Otras implementaciones

Me gusta implementar lisp en un lenguaje, así que acá hay otras implementaciones de lisp

* [Ruby](https://github.com/lfborjas/minimalisp/tree/ruby)
* [Javascript](https://github.com/lfborjas/minimalisp/tree/javascript)
* [Scheme](https://github.com/lfborjas/minimalisp/tree/scheme)

Además, Peter Norvig ha implementado lisp, bueno, una versión más completa, en un par de lenguajes:

* [Python](http://norvig.com/lispy2.html) 
* [Java](http://norvig.com/jscheme.html)

##¿Por qué?

Para que recordemos que la programación es simple y basada, como vemos en la charla, en unos pocos conceptos
básicos que después abstraemos hasta el infinito. Y que es posible que lenguajes que se apeguen a esos principios
logren construir cosas complejas.


##Referencias

Esta charla está basada en el artículo de Paul Graham ["The roots of lisp"](http://www.paulgraham.com/rootsoflisp.html)
y, éste, a su vez, en el artículo de John McCarthy  ["Recursive Functions of Symbolic Expressions and Their Computation by Machine, Part I"](http://www-formal.stanford.edu/jmc/recursive/recursive.html).

