function evListener(instance){
	with(instance) {
		lastSubscriptionId = 0;
		subscriptions = ds_list_create();

		cleanUpSubscriptions = function() {
			if(is_undefined(subscriptions)) {
				return;	
			}
			
			ds_list_destroy(subscriptions);
			lastSubscriptionId = 0;
			subscriptions = undefined;
		}

		function unsubscribe(subscriptionId) {
			if(is_undefined(subscriptions)) {
				return;	
			}
			
			var pos = ds_list_findIndexOf(subscriptions, function(m, __i, _subscriptionId){
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
			}, { evName:evName, _args:_args });
			
			removeExpiredSubscriptions();
		}

		function evCall(evName) {
			for(var i = 0; i < ds_list_size(subscriptions); i++) {
				var s = ds_list_find_value(subscriptions, i);
				if (s.ttl != 0) {
					if (s.event == evName) {
						s.action(s.args);
				
						if (s.ttl > 0) {
							s.ttl--;	
						}
					}
				}
			}
			
			removeExpiredSubscriptions();
		}
		
		function removeExpiredSubscriptions() {
			//	TODO	Optimize
			ds_list_removeAll(subscriptions, function(value, idx, __args) {
				return (value.ttl == 0) ? value : pointer_null;
			}, undefined);
		}
		
		function evSubscribeOnce(evName, action, args) {
			var subscription = {
				id: ++lastSubscriptionId,
				event: evName,
				action: action,
				args: args,
				ttl: 1
			};
	
			ds_list_add(subscriptions, subscription);
	
			return lastSubscriptionId;
		}

		function evSubscribe(evName, action, args) {
			var subscription = {
				id: ++lastSubscriptionId,
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