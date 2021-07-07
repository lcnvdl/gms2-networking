function nw_RpcExecutorServer(_rpc, _package) : nw_RpcExecutorBase(_rpc, _package) constructor {
	static Process = function(isFirstCall) {
		if (nw_is_server()) {
			rpc.Call(GetArgs());
			return false;
		}
		else {
			if (isFirstCall) {
				package.from = RpcFunctionExecutor.Client;
				package.withReply = true;
				var _socket = nw_get_socket();
				nw_custom_send_to(_socket, NwMessageType.rpcCallExecute, package);
				return true;
			}
		}
		
		return false;
	}
}