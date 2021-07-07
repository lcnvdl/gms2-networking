function nw_RpcExecutorSender(_rpc, _package) : nw_RpcExecutorBase(_rpc, _package) constructor {
	static Process = function(isFirstCall) {
		if (IsSender()) {
			rpc.Call(GetArgs());
			// return true;
		}
		else {
			throw "You can't send a RPC from a receiver to a sender";
		}
		
		return false;
	}
}