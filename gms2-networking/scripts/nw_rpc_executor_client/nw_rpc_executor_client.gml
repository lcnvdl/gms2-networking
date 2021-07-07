/// @desc The execution target is a client.
function nw_RpcExecutorClient(_rpc, _package) : nw_RpcExecutorBase(_rpc, _package) constructor {
	static Process = function(isFirstCall) {
		if (nw_is_client()) {
			//	Run in local code
			result = rpc.Call(GetArgs());
			
			if (isFirstCall) {
				//	Replication
				package.from = RpcFunctionExecutor.Client;
				var _socket = nw_get_socket();
				nw_custom_send_to(_socket, NwMessageType.rpcCallReplicate, package);
			}
		}
		else if(nw_is_server()) {
			package.from = RpcFunctionExecutor.Server;
			package.withReply = true;
			nw_broadcast(NwMessageType.rpcCallExecute, package);
			return true;
		}
		
		return false;
	}
}