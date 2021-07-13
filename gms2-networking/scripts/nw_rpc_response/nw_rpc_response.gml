/**
* @file RPC Response.
* @author Forja Games <forjagames.com@gmail.com>
* @license MIT
*/

function nw_RPCResponse() constructor {
	data = {};
	isValid = true;
	headers = {};
	
	static SetData = function(_data) {
		isValid = true;
		data = _data;
	};
	
	static ReplyTo = function(_uuid, replyTo) {
		assert_is_not_undefined(_uuid, "Network entity ID is undefined");
		assert_is_string(_uuid, "Network entity ID must be a string");
		assert_is_not_undefined(replyTo, "Message ID is undefined");
		assert_is_string(replyTo, "Message ID must be a string");
		
		headers[$ "id"] = _uuid;
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
