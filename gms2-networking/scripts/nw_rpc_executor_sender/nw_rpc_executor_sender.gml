function nw_RpcExecutorSender(_rpc, _package) : nw_RpcExecutorBase(_rpc, _package) constructor {
	static Process = function(isFirstCall) {
		if (IsSender()) {
			rpc.Call(GetArgs());
			return true;
		}
		
		return false;
	}
}