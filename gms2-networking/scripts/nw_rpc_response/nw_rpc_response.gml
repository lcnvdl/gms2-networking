function nw_RPCResponse() constructor {
	data = {};
	isValid = true;
	
	static SetError = function(err) {
		isValid = false;
		data = err;
	};
}
