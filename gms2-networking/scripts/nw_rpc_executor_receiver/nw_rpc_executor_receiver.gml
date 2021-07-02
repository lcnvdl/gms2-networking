function nw_RpcExecutorReceiver(_rpc, _package) : nw_RpcExecutorBase(_rpc, _package) constructor {
	static Process = function(isFirstCall) {
		if (IsReceiver()) {
			rpc.Call(GetArgs());
			return false;
		}
		else {	//	Sender
			if (nw_is_client()) {
				package.from = RpcFunctionExecutor.Sender;
				var _socket = nw_get_socket();
				nw_custom_send_to(_socket, NwMessageType.rpcCall, package);
				return true;
			}
			else if (nw_is_server()) {
				package.from = RpcFunctionExecutor.Sender;
				nw_broadcast(NwMessageType.rpcCall, package);
				return true;
			}
		}
		
		return false;
	}
}