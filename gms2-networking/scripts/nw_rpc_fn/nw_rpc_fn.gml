function nw_RpcFunction(_name, _fnCall, _opts) constructor {
	name = _name;
	fnCall = _fnCall;
	opts = _opts;
	/// @desc Who can call the function
	allowance = !is_undefined(_opts) ? _opts.allowance : RpcFunctionCallerAllowance.Everyone;
	/// @desc Who will run the function
	executors = !is_undefined(_opts) ? _opts.executors : [RpcFunctionExecutor.Everyone];
	
	static Call = function(_args) {
		fnCall(_args);	
	};
}


