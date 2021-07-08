/**
* @file RPC Function.
* @author Forja Games <forjagames.com@gmail.com>
* @license MIT
*/

function nw_RpcFunction(_instance, _name, _fnCall) constructor {
	name = _name;
	fnCall = _fnCall;
	instance = _instance;
	
	static Call = function(_args) {
		return fnCall(_args);
	};
}


