/// @desc The execution target is itself.
function nw_RpcExecutorOwner(_rpc, _package) : nw_RpcExecutorBase(_rpc, _package) constructor {
	static Process = function(isFirstCall) {
		result = rpc.Call(GetArgs());
		return false;
	}
}