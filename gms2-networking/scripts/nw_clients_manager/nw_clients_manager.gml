function nw_ClientsManager() constructor {
	clients = ds_list_create();
	clientsInfo = ds_map_create();	
	
	static Add = function(socket) {
		ds_list_add(clients, socket);
		ds_map_add(clientsInfo, socket, { X: -1, Y: -1, Range: 2000 });
	};
	
	static Remove = function(socket) {
		ds_list_delete(clients, ds_list_find_index(clients, socket));
		ds_map_delete(clientsInfo, socket);
	};
	
	static GetInfo = function(socket) {
		var clientInfo = ds_map_find_value(clientsInfo, socket);
		return clientInfo;
	};
	
	static Dispose = function() {
		ds_list_destroy(clients);
		ds_map_destroy(clientsInfo);
	};
}

