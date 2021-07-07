function nw_RpcExecutorBase(_rpc, _package) constructor {
	package = _package;
	rpc = _rpc;
	result = undefined;
	
	static GetInstanceUuid = function() {
		return package.instance;	
	}
	
	static IsSender = function() {
		var _uuid = GetInstanceUuid();
		return !is_undefined(_uuid) && nw_sender_exists(GetInstanceUuid());
	}
	
	static IsReceiver = function() {
		var _uuid = GetInstanceUuid();
		return !is_undefined(_uuid) && !nw_sender_exists(GetInstanceUuid());
	}
	
	static GetArgs = function() {
		return package.args;		
	}
	
	static Process = function(isFirstCall) {
		return false;
	}
}
