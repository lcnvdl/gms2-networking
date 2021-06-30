currentOsVersion = undefined; 

if(nw_is_server()) {
	var sender = nw_add_empty_sender(id, undefined);
	
	currentOsVersion = {
		osType: os_type,
		osVersion: os_version,
		region: os_get_region()
	};
	
	getServerInfo = function() {
		return rpc_example_o.currentOsVersion;
	};
	
	nw_instance_register_function(id, "getServerInfo", getServerInfo);
}
else {
	getServerInfo = function() {
		nw_call_function(id, "getServerInfo", undefined, function(response) {
			if (!is_undefined(response)) {
				if (response.isValid) {
					var data = response.data;
					rpc_example_o.currentOsVersion = data;
				}
			}
		});
	};
}