function OrderedEnumerator(): BaseEnumerator() constructor {
	static GetKeys = function() {
		var keys = new ArrayList();
		
		Reset();
		
		while(MoveNext()) {
			var pair = GetCurrent();
			keys.Add(pair.key)
		}
		
		return keys;
	};
	
	static GetValues = function() {
		var values = new ArrayList();
		
		Reset();
		
		while(MoveNext()) {
			var pair = GetCurrent();
			values.Add(pair.value)
		}
		
		return values;
	};
	
	static ToDictionary = function() {
		var dict = new Dictionary();
		
		Reset();
		
		while(MoveNext()) {
			var pair = GetCurrent();
			dict.Set(pair.key, pair.value);
		}
		
		return dict;
	};
}