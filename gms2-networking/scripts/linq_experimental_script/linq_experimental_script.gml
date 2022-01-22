/*#macro lm_ (function(){return 
#macro _lm ;})
#macro lm1_ (function(arg1){return 
#macro lm2_ (function(arg1, arg2){return 
#macro _lm1_ ,(function(arg1){return 
#macro _from GetEnumeratorOf
#macro _auto GetStructureOf

function ForEach(_x, _cb) {
	GetEnumeratorOf(GetStructureOf(_x)).ForEach(_cb);
}

*/