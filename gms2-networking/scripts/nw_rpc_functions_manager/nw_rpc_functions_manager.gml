/**
* @file RPC Functions Manager.
* @author Forja Games <forjagames.com@gmail.com>
* @license MIT
*/

function nw_RpcFunctionsManager(_instance) constructor {
	rpcFunctions = {};
	rpcWaiters = {};
	instance = _instance;
	
	static Register = function(name, fnCall) {
		rpcFunctions[$ name] = new nw_RpcFunction(instance, name, fnCall);	
	};
	
	static CallVoidFunction = function(fnName, fnArgs) {
		rpcFunctions[$ fnName].Call(fnArgs);
	};
	
	static CallFunction = function(fnName, fnArgs) {
		var result = rpcFunctions[$ fnName].Call(fnArgs);
		return result;
	};
	
	static ProcessReply = function(waiterId, fullReply) {
		var waiter = rpcWaiters[$ waiterId];
		
		if (waiter.ttl > 0) {
			waiter.cb(fullReply.data, fullReply.isValid, fullReply);
			waiter.ttl = 0;
			waiter.finished = true;
		}
		
		// variable_struct_remove(rpcWaiters, waiterId);
	}
	
	static AddWaiter = function(waiterId, fnCallback) {
		rpcWaiters[$ waiterId] = {
			id: waiterId,
			cb: fnCallback,
			ttl: 30,
			finished: false
		};
	};
	
	static Update = function(dt) {
		struct_foreach(rpcWaiters, function(waiter, k, _dt) {
			waiter.ttl -= _dt;
			if (waiter.ttl <= 0) {
				if(!waiter.finished) {
					var response = new nw_RPCResponse();
					response.SetError({error: "Timeout"});
					waiter.cb(response.data, false, response);
					waiter.finished = true;	
				}
				variable_struct_remove(waiter, k);	
			}
		}, dt);
	};
}