function getJsonSerializer() {
	return {
		Serialize: function(obj) {
			return json_stringify(obj);
		},
		Deserialize: function(text) {
			return json_parse(text);
		}, 
	};
}