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
		nw_broadcast_exclude(pck.fn, pck.args, [socket]);
	}
	
	static ReceiverCallToSender = function(pck, socket) {
		var instance = nw_get_instance(pck.id);
		if (!is_undefined(instance) && instance_exists(instance)) {
			var sender = nw_get_sender(pck.id);
			if (is_undefined(sender)) {
				if(nw_is_server()) {
					//	Server must find the sender
					var _socket = socket;
					instance.nwRpc.AddWaiter(pck.replyTo, function(result) {
						global.nwNetworkManager.nwCustomSend(_socket, 
							NwMessageType.rpcReceiverFunctionReply, 
							result);
					});
					
					nw_broadcast_exclude(pck.fn, pck.args, [socket]);
				}
			}
			else {
				var response = _CallRpcFunctionAndGenerateResponse(instance, pck);
				
				global.nwNetworkManager.nwCustomSend(socket, NwMessageType.rpcReceiverFunctionReply, response.Serialize());
			}
		}
	}
	
	static FindSenderAndReply = function(pck, socket) {
		var instance = nw_get_instance(pck.id);
		if (!is_undefined(instance) && instance_exists(instance) && nw_sender_exists(pck.id)) {
			var response = _CallRpcFunctionAndGenerateResponse(instance, pck);
			
			global.nwNetworkManager.nwCustomSend(socket, NwMessageType.rpcSenderFunctionReply, response.Serialize());
		}
	}
	
	static SenderCallToReceiver = function(pck, socket) {
		var instance = nw_get_instance(pck.id);
		if (!is_undefined(instance) && instance_exists(instance)) {
			var response = _CallRpcFunctionAndGenerateResponse(instance, pck);
			
			global.nwNetworkManager.nwCustomSend(socket, NwMessageType.rpcSenderFunctionReply, response.Serialize());
		}
	}
	
	static ReceiveReply = function(pck) {
		var instance = nw_get_instance(pck.id);			
		if (!is_undefined(instance) && instance_exists(instance)) {
			var waiterId = pck.replyTo;
			
			instance.nwRpc.ProcessReply(waiterId, pck);
		}
	}
	
	static _CallRpcFunctionAndGenerateResponse = function(instance, pck) {
		var response = new nw_RPCResponse();
		try {
			var result = instance.nwRpc.CallFunction(pck.fn, pck.args);
			response.SetData(result);
		}
		catch(err) {
			response.SetError(err);
		}
			
		response.ReplyTo(pck.id, pck.replyTo);
		return response;
	}
}
