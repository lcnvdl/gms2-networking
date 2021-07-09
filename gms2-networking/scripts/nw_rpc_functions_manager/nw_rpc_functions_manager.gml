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
	
	static ProcessReply = function(waiterId, reply) {
		var waiter = rpcWaiters[$ waiterId];
		
		if (waiter.ttl > 0) {
			waiter.fnCallback(reply);
			waiter.ttl = 0;
		}
		
		// variable_struct_remove(rpcWaiters, waiterId);
	}
	
	static AddWaiter = function(waiterId, fnCallback) {
		rpcWaiters[$ waiterId] = {
			id: waiterId,
			cb: fnCallback,
			ttl: 30
		};
	};
	
	static Update = function(dt) {
		struct_foreach(rpcWaiters, function(waiter, k, _dt) {
			waiter.ttl -= _dt;
			if (waiter.ttl <= 0) {
				variable_struct_remove(waiter, k);	
			}
		}, dt);
	};
	
	///	@deprecated
	static LocalCall = function(_package) {
		var rpc = rpcFunctions[$ _package.name];
		var executorInstance = new nw_RpcExecutorOwner(rpc, _package);
		executorInstance.Process(false);
		return executorInstance.result;
	}
	
	///	@deprecated
	static Call = function(fnName, fnArgs, isFirstCall, callback) {
		var rpc = rpcFunctions[$ fnName];
		var isSender = false;
		var isReceiver = false;
		var instanceId = undefined;
		
		if (!is_undefined(instance)) {
			instanceId = nw_instance_get_uuid(instance);
			isSender = nw_sender_exists(instanceId);
			isReceiver = !isSender;
		}
		
		if (rpc.allowance == RpcFunctionCallerAllowance.Everyone ||
			(rpc.allowance == RpcFunctionCallerAllowance.Client && nw_is_client()) ||
			(rpc.allowance == RpcFunctionCallerAllowance.Server && nw_is_server()) ||
			(rpc.allowance == RpcFunctionCallerAllowance.Owner && rpc.instance == instance) ||
			(rpc.allowance == RpcFunctionCallerAllowance.Receiver && isReceiver) ||
			(rpc.allowance == RpcFunctionCallerAllowance.Sender && isSender)
		) {
			for(var i = 0; i < array_length(rpc.executors); i++) {
				var executor = rpc.executors[i];
				var package = {
					id: getUuid(),
					instance: instanceId, 
					name: fnName, 
					args: fnArgs,
					from: -1,
					to: executor,
					withReturn: false
				};

				var executorInstance = nw_RpcExecutorFactory(executor, rpc, package);
				var waitForReply = executorInstance.Process(isFirstCall);
			
				if (waitForReply) {
					rpcWaiters[$ package.id] = { package: package, callback: callback, timeout: 30000 };
				}
				else {
					if (!is_undefined(callback)) {
						var response = new nw_RPCResponse();
						try {
							response.data = executorInstance.result;
							callback(response);	
						}
						catch(err) {
							response.data = err;
							response.isValid = false;
							callback(response);
						}
					}
				}
			}
			
			return true;
		}
	
		return false;
	}
}