function nw_RpcManager() constructor {
	static ProcessRpcCallAsServer = function(pck, socket) {
		
	}
	
	static ProcessRpcCallReplicateAsServer = function(pck, socket) {
		if (pck.to == RpcFunctionExecutor.Client) {
			pck.waitForReply = false;
			nw_broadcast_exclude(NwMessageType.rpcCallExecute, pck, [socket]);
		}
		else {
			throw "Cannot replicate the package. The target is not valid.";
		}
	}
	
	static ProcessRpcCallExecuteAsServer = function(pck, socket) {
		var instance = nw_get_instance(pck.id);
		if (!is_undefined(instance) && instance_exists(instance)) {
			var shouldReply = pck.waitForReply;
			instance.rpc.Call(package.name, package.args, false, undefined);
			if(shouldReply) {
				var result = instance.rpc.result;
				pck.result = result;
				nw_send_to(socket, NwMessageType.rpcCallReply, pck);
			}
		}
	}
	
	static ProcessRpcCallAsClient = function(pck, socket) {
	}
	
	static ProcessRpcCallExecuteAsClient = function(pck, socket) {
		var instance = nw_get_instance(pck.id);
		if (!is_undefined(instance) && instance_exists(instance)) {
			var shouldReply = pck.waitForReply;
			var result = instance.rpc.LocalCall(pck);
			if(shouldReply) {
				pck.result = result;
				nw_send_to(socket, NwMessageType.rpcCallReply, pck);
			}
		}
	}
}
