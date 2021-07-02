function nw_RpcExecutorFactory(_executor, _rpc, _package) {
	if (_executor == RpcFunctionExecutor.Owner) {
		return new nw_RpcExecutorOwner(_rpc, _package);	
	}
	else if (_executor == RpcFunctionExecutor.Receiver) {
		return new nw_RpcExecutorReceiver(_rpc, _package);	
	}
	else if (_executor == RpcFunctionExecutor.Sender) {
		return new nw_RpcExecutorSender(_rpc, _package);	
	}
	else if (_executor == RpcFunctionExecutor.Client) {
		return new nw_RpcExecutorClient(_rpc, _package);	
	}
	else if (_executor == RpcFunctionExecutor.Server) {
		return new nw_RpcExecutorServer(_rpc, _package);	
	}
	else {
		throw "Unknown executor";	
	}
}