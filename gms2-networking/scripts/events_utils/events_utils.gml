function evListener(instance){
	with(instance) {
		lastSubscriptionId = 0;
		subscriptions = ds_list_create();

		cleanUpSubscriptions = function() {
			ds_list_destroy(subscriptions);	
		}

		function unsubscribe(subscriptionId) {
			var pos = ds_list_findIndex(subscriptions, function(m, __i, _subscriptionId){
				return m.id == _subscriptionId;
			}, subscriptionId);
	
			if(pos >= 0) {
				ds_list_delete(subscriptions, pos);		
			}
		}

		function evCallWithArgs(evName, _args) {
			ds_list_foreach(subscriptions, function(s, i, params) {
				if (s.ttl != 0) {
					if (s.event == params.evName) {
						s.action(s.args, params._args);
				
						if (s.ttl > 0) {
							s.ttl--;	
						}
					}
				}
			}, {evName:evName, _args:_args});
		}

		function evCall(evName) {
			ds_list_foreach(subscriptions, function(s, i, _evName) {
				if (s.ttl != 0) {
					if (s.event == _evName) {
						s.action(s.args);
				
						if (s.ttl > 0) {
							s.ttl--;	
						}
					}
				}
			}, evName);
		}

		function evSubscribe(evName, action, args) {
			var subscription = {
				id: lastSubscriptionId++,
				event: evName,
				action: action,
				args: args,
				ttl: -1
			};
	
			ds_list_add(subscriptions, subscription);
	
			return lastSubscriptionId;
		}
	}
}