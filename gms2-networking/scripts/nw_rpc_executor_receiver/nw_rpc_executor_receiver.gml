/// @desc The execution target is a receiver.
function nw_RpcExecutorReceiver(_rpc, _package) : nw_RpcExecutorBase(_rpc, _package) constructor {
	static Process = function(isFirstCall) {
		if (IsReceiver()) {
			rpc.Call(GetArgs());
			return false;
		}
		else {	
			assert_is_true(IsSender());
			
			//	Sender
			if (nw_is_client()) {
				package.from = RpcFunctionExecutor.Sender;
				package.withReply = true;
				var _socket = nw_get_socket();
				nw_custom_send_to(_socket, NwMessageType.rpcCallExecute, package);
				return true;
			}
			else if (nw_is_server()) {
				package.from = RpcFunctionExecutor.Sender;
				package.withReply = true;
				nw_broadcast(NwMessageType.rpcCallExecute, package);
				return true;
			}
		}
		
		return false;
	}
}