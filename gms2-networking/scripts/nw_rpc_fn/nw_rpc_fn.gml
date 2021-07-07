/**
* @file RPC Function.
* @author Forja Games <forjagames.com@gmail.com>
* @license MIT
*/

function nw_RpcFunction(_instance, _name, _fnCall, _opts) constructor {
	name = _name;
	fnCall = _fnCall;
	opts = _opts;
	instance = _instance;
	
	/// @desc Who can call the function (caller)
	allowance = RpcFunctionCallerAllowance.Everyone;
	/// @desc Who will run the function (target)
	executors = [];
	
	if (!is_undefined(_opts)) {
		if (variable_struct_exists(_opts, "isOwner") && _opts.isOwner) {
			array_push(executors, RpcFunctionExecutor.Owner);
			allowance = RpcFunctionCallerAllowance.Owner;
		}
		
		if (variable_struct_exists(_opts, "allowance")) {
			allowance = _opts.allowance;
		}
		
		if (variable_struct_exists(_opts, "executors")) {
			executors = _opts.executors;
		}
	}
	
	static IsOwned = function() {
		return allowance == RpcFunctionCallerAllowance.Owner;	
	};
	
	static Call = function(_args) {
		return fnCall(_args);
	};
}


