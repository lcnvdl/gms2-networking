function nw_RpcExecutorClient(_rpc, _package) : nw_RpcExecutorBase(_rpc, _package) constructor {
	static Process = function(isFirstCall) {
		if (nw_is_client()) {
			rpc.Call(GetArgs());
			if (isFirstCall) {
				package.from = RpcFunctionExecutor.Client;
				var _socket = nw_get_socket();
				nw_custom_send_to( _socket, NwMessageType.rpcCall, package);
			}
		}
		else {
			package.from = RpcFunctionExecutor.Server;
			nw_broadcast(NwMessageType.rpcCall, package);
			return true;
		}
		
		return false;
	}
}