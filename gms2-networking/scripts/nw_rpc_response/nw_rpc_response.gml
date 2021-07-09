function nw_RPCResponse() constructor {
	data = {};
	isValid = true;
	headers = {};
	
	static SetData = function(_data) {
		isValid = true;
		data = _data;
	};
	
	static ReplyTo = function(replyTo) {
		assert_is_not_undefined(replyTo);
		assert_is_string(replyTo);
		headers[$ "replyTo"] = replyTo;
	};
	
	static SetError = function(err) {
		isValid = false;
		data = err;
	};
	
	static Serialize = function() {
		var result = {
			data: data,
			isValid: isValid
		};
		
		if (variable_struct_names_count(headers) > 0) {
			struct_foreach(headers, function(header, key, _result) {
				_result[$ key] = header;
			}, result);	
		}
		
		return result;
	};
}
