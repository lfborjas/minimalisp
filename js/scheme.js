//Javascript translation of lis.py
//Original by Peter Norvig: http://norvig.com/lispy.html
/*For representing the environments (a.k.a a simple symbol table)*/


Env = function(params, args, outer){
    for (var i = 0; params && i < params.length ; i++) {
        this[params[i]] = args[i]; 
    };
    this.outer = outer;

    //Find the innermost environment for the variable v
    this.find = function(v){
      return (this[v] !== undefined ? this : this.outer.find(v));
    };
};

//The global environment, with pre-defined operations
global_env = (function(e){
    //Add all math methods
    try{
        Object.getOwnPropertyNames(Math).forEach(function(m){
            if(typeof Math[m] == "function"){
                e[m] = function(){return Math[m].call(this, Array.prototype.slice.call(arguments))} ;
            }
        });
    }catch(r){
        //no math methods for you :(
    }
    //binary ops
    "+ - * / > < >= <= == ===".split(" ").forEach(function(o){
        e[o] = function(a,b){return eval(a+o+b)}
    });
    
    //unary ops:
    e["not"] = function(x){return !x;}
    e["length"] = function(l){return l.length;}

    //lispy operations
    e["="] = function(a,b){return a == b}
    e["equal?"] = e["="]
    e["eq?"] = function(a,b){return a === b}
    
    e.cons = function(a,b){return [a].concat(b)}
    e.car  = function(l){  return l[0]}
    e.cdr  = function(l){  return l.slice(1)}
    e.append=function(l,m){return l.concat(m)}
    e.list = function(){   return Array.prototype.slice.call(arguments)}
    e["list?"]=function(a){ return a instanceof Array}
    e["null?"]=function(l){ return l.length == 0}
    e["symbol?"]=function(e){return typeof e == "string"}
    return e;
})(new Env());

function _eval(x, env){
   env = typeof env == "undefined" ? global_env : env;
   if(typeof x == "string")
       return env.find(x)[x];
   else if(!(x instanceof Array))
       return x;
   else
       switch(x[0]){
        case "quote":
            return x[1];
        case "if":
            return _eval(_eval(x[1], env) ? x[2] : x[3]);
        case "set!":
            env.find(x[1])[x[1]] = _eval(x[2], env)
            break;
        case "define":
            env[x[1]] = _eval(x[2], env)
            break;
        case "lambda":
            return function(){return _eval(x[2], new Env(x[1], Array.prototype.slice.call(arguments), env))}
        case "begin":
            x.slice(1).forEach(function(exp){
                val = _eval(exp, env)
            });
            return val;
        default:
            exps = x.map(function(exp){
               return _eval(exp, env); 
            });
            fun = exps.shift()
            return fun.apply(this, exps);
       }
}

String.prototype.to_sexp = function(){

    function read_from(tokens){
        if(tokens.length==0)
            throw new SyntaxError("Unexpected EOF while reading");
        token = tokens.shift();
        switch(token){
            case "(":
                var L = [];
                while(tokens[0] != ")")
                    L.push(read_from(tokens));
                tokens.shift();
                return L;
            case ")":
                throw new SyntaxError("Unexpected ')'");
            default:
                return atom(token);

        }
    }

    atom = function(e){
        return Number(e) || e.toString() ;
    }
    e = this;//somehow, calling this directly below caused infinite recursion (at least in the node REPL)
    return read_from(e.replace(/[()]/g, function(match){return " "+match+" "}).split(/\s+/).slice(1,-1));
}

Array.prototype.to_lisp = function(){
    return "("+
            this.map(function(e){
                return to_lisp(e);
            }).join(" ")
            +")";
}

//was extending the object prototype, but that turns out to be verboten...
//http://erik.eae.net/archives/2005/06/06/22.13.54/

function to_lisp(o){
    return o['to_lisp'] ? o.to_lisp() : o.toString();
}

//now, the REPL, using jquery-console
$(function(){
     var console1 = $('<div class="console1"></div>');
     $('#repl').append(console1);
     var controller1 = console1.console({
         promptLabel: "jscm >",
         commandValidate: function(line){
           return true; 
         },
         commandHandle: function(line){
               try{
                    return [{msg: to_lisp(_eval(line.to_sexp())), className: "feedback"}];
               }catch(e){
                    return [{msg: e.message, className:"error"}];
               }
         },
       autofocus:true,
       animateScroll:true,
       promptHistory:true,
     });

});
