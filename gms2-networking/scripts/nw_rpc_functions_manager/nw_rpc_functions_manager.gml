/**
* @file RPC Functions Manager.
* @author Forja Games <forjagames.com@gmail.com>
* @license MIT
*/

function nw_RpcFunctionsManager(_instance) constructor {
	rpcFunctions = {};
	rpcWaiters = {};
	instance = _instance;
	
	static Register = function(name, fnCall, _opts) {
		rpcFunctions[$ name] = new nw_RpcFunction(name, fnCall, _opts);	
	};
	
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
			(rpc.allowance == RpcFunctionCallerAllowance.Owner && id == instance) ||
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
					to: executor
				};

				var executorInstance = nw_RpcExecutorFactory(executor, rpc, package);
				var waitForReply = executorInstance.Process(isFirstCall);
			
				if (waitForReply) {
					rpcWaiters[$ package.id] = { package: package, callback: callback, timeout: 30000 };
				}
			}
		}
	
		return -1;
	}
}