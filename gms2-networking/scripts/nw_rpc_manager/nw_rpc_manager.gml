/**
* @file RPC Manager.
* @author Forja Games <forjagames.com@gmail.com>
* @license MIT
*/

function nw_RpcManager() constructor {
	static BroadcastCall = function(pck) {
		var instance = nw_get_instance(pck.id);			
		if (!is_undefined(instance) && instance_exists(instance)) {
			instance.nwRpc.CallVoidFunction(pck.fn, pck.args);
		}
	}
	
	static BroadcastReplicate = function(pck, socket) {
		nw_broadcast_exclude(NwMessageType.rpcSenderBroadcastReplicate, pck, [socket]);
	}
	
	static SenderCallToReceiver = function(pck, socket) {
		var instance = nw_get_instance(pck.id);			
		if (!is_undefined(instance) && instance_exists(instance)) {
			var response = new nw_RPCResponse();
			try {
				var result = instance.nwRpc.CallFunction(pck.fn, pck.args);
				response.SetData(result);
			}
			catch(err) {
				response.SetError(err);
			}
			
			response.ReplyTo(pck.replyTo);
			
			global.nwNetworkManager.nwCustomSend(socket, NwMessageType.rpcReceiverFunctionReply, response.Serialize());
		}
	}
	
	static ReceiveReply = function(pck) {
		var instance = nw_get_instance(pck.id);			
		if (!is_undefined(instance) && instance_exists(instance)) {
			var waiterId = pck.replyTo;
			
			instance.nwRpc.ProcessReply(waiterId, pck.data);
		}
	}
	
	///	@deprecated
	static ProcessRpcCallAsServer = function(pck, socket) {
		
	}
	
	///	@deprecated
	static ProcessRpcCallReplicateAsServer = function(pck, socket) {
		if (pck.to == RpcFunctionExecutor.Client) {
			pck.waitForReply = false;
			nw_broadcast_exclude(NwMessageType.rpcCallExecute, pck, [socket]);
		}
		else {
			throw "Cannot replicate the package. The target is not valid.";
		}
	}
	
	///	@deprecated
	static ProcessRpcCallExecuteAsServer = function(pck, socket) {
		var instance = nw_get_instance(pck.id);
		if (!is_undefined(instance) && instance_exists(instance)) {
			var shouldReply = pck.waitForReply;
			instance.rpc.Call(pck.name, pck.args, false, undefined);
			if(shouldReply) {
				var result = instance.rpc.result;
				pck.result = result;
				nw_send_to(socket, NwMessageType.rpcCallReply, pck);
			}
		}
	}
	
	///	@deprecated
	static ProcessRpcCallAsClient = function(pck, socket) {
	}
	
	///	@deprecated
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
