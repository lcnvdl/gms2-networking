function nw_ClientsManager(_settings) constructor {
	clients = ds_list_create();
	clientsInfo = ds_map_create();
	requireWatchPoints = _settings.requireWatchPoints;
	
	static Add = function(socket) {
		ds_list_add(clients, socket);
		var client = new nw_ClientInfo(socket);
		ds_map_add(clientsInfo, socket, client);
	};
	
	static Remove = function(socket) {
		var client = GetInfo(socket);
		client.Dispose();
		
		ds_list_delete(clients, ds_list_find_index(clients, socket));
		ds_map_delete(clientsInfo, socket);
	};
	
	static GetInfo = function(socket) {
		var clientInfo = ds_map_find_value(clientsInfo, socket);
		return clientInfo;
	};
	
	static Dispose = function() {
		ds_map_foreach(clientsInfo, function(client, _socket) {
			client.Dispose();
		});
		
		ds_list_destroy(clients);
		ds_map_destroy(clientsInfo);
	};
}

