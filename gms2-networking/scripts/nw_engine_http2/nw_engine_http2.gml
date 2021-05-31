//	How to use?
//	1) Download and import HTTP2 dll into your game. https://www.maartenbaert.be/game-maker-dlls/http-dll-2
//	2) Make shure that HTTP2 buffer methods starts with a "h" letter. Example: hbuffer_create()
//	3) Uncomment the code below.
//	4) Override the default engine. Code: global.nwNetworkManagerFactory = function() { return getHttp2NetworkEngine(); };

/*
//	HTTP2 NetworkEngine Implementation

function getHttp2NetworkEngine() {
	return {
		serve: _nwHttp2Serve,
		connect: _nwHttp2Connect,
		receive: _nwHttp2Receive,
		send: _nwHttp2Send,
		destroySocket: _nwHttp2DestroySocket,
		createBuffer: _nwHttp2CreateBuffer,
		destroyBuffer: _nwHttp2DestroyBuffer,
		evStep: _nwHttp2Step,
		evAsync: undefined
	};
}

function _nwHttp2Step(socket, buffer, onAsyncCallback) {
	if (global._nwHttp2SocketType == 0) {
		socket_update_read(socket);

		while socket_read_message(socket, buffer) {
			//	Async event (message receive)
			ds_map_clear(global._nwHttpAsyncLoad);
			ds_map_add(global._nwHttpAsyncLoad, "socket", socket);
			ds_map_add(global._nwHttpAsyncLoad, "buffer", buffer);
			ds_map_add(global._nwHttpAsyncLoad, "type", network_type_data);
			onAsyncCallback(global._nwHttpAsyncLoad);
		}

		var s = socket_get_state(socket);
		if (s == 2 && !global._nwHttpClientConnected) {
		    global._nwHttpClientConnected = true;
			
			//	Async event
			ds_map_clear(global._nwHttpAsyncLoad);
			ds_map_add(global._nwHttpAsyncLoad, "socket", socket);
			ds_map_add(global._nwHttpAsyncLoad, "type", network_type_connect);
			onAsyncCallback(global._nwHttpAsyncLoad);
		}
		if (s == 4) {
		    show_message("Connection closed.");
		    game_end();
		    exit;
		}
		//if (s == 5  or socket_get_write_data_length(socket) > max_write_data_length) {
		if (s == 5) {
			//	Async event
			ds_map_clear(global._nwHttpAsyncLoad);
			ds_map_add(global._nwHttpAsyncLoad, "socket", socket);
			ds_map_add(global._nwHttpAsyncLoad, "type", network_type_disconnect);
			onAsyncCallback(global._nwHttpAsyncLoad);
			
			//	Disconnect
		    socket_reset(socket);
			global._nwHttpClientConnected = false;
		}
		else {
			socket_update_write(socket);
		}
	}
	else {
		while listeningsocket_can_accept(socket) {
		    var clientSocket = socket_create();
		    listeningsocket_accept(socket, clientSocket);
			ds_list_add(global._nwHttp2SocketClients, clientSocket);
		
			//	Async event
			ds_map_clear(global._nwHttpAsyncLoad);
			ds_map_add(global._nwHttpAsyncLoad, "socket", clientSocket);
			ds_map_add(global._nwHttpAsyncLoad, "type", network_type_connect);
			onAsyncCallback(global._nwHttpAsyncLoad);
		}

		for(var i = 0; i < ds_list_size(global._nwHttp2SocketClients); i++) {
			var clientSocket = ds_list_find_value(global._nwHttp2SocketClients, i);
		
			socket_update_read(clientSocket);

			while socket_read_message(clientSocket, buffer) {
				//	Async event
				ds_map_clear(global._nwHttpAsyncLoad);
				ds_map_add(global._nwHttpAsyncLoad, "socket", clientSocket);
				ds_map_add(global._nwHttpAsyncLoad, "buffer", buffer);
				ds_map_add(global._nwHttpAsyncLoad, "type", network_type_data);
				onAsyncCallback(global._nwHttpAsyncLoad);
			}

			var s = socket_get_state(clientSocket);
			//if (s = 4 || s = 5) or socket_get_write_data_length(socket) > max_write_data_length {
			if (s = 4 || s = 5) {
				//	Async event
				ds_map_clear(global._nwHttpAsyncLoad);
				ds_map_add(global._nwHttpAsyncLoad, "socket", clientSocket);
				ds_map_add(global._nwHttpAsyncLoad, "type", network_type_disconnect);
				onAsyncCallback(global._nwHttpAsyncLoad);
				//	Remove
				var ix = ds_list_find_index(global._nwHttp2SocketClients, clientSocket);
				ds_list_delete(global._nwHttp2SocketClients, ix);
			}
			else {
				socket_update_write(clientSocket);
			}
		}

		//if !listeningsocket_is_listening(listeningsocket) {
		//    show_message("Can't listen for incoming connections!");
		//    game_end();
		//    exit;
		//}
	}
}

function _nwHttp2DestroySocket(socket) {
	if(global._nwHttp2SocketType == 0) {
		socket_destroy(socket);	
	}
	else {
		listeningsocket_destroy(socket);
		ds_list_destroy(global._nwHttp2SocketClients);
		global._nwHttp2SocketClients = undefined;
	}
	
	ds_map_destroy(global._nwHttpAsyncLoad);
}

function _nwHttp2CreateBuffer(bufferSize, bufferType, alignment) {
	return hbuffer_create();
}

function _nwHttp2DestroyBuffer(bufferId) {
	hbuffer_destroy(bufferId);
}

function _nwHttp2Serve(port){
	global._nwHttp2SocketType = 1;
	global._nwHttpAsyncLoad = ds_map_create();
	global._nwHttp2SocketClients = ds_list_create();
	var socket = listeningsocket_create();
	listeningsocket_start_listening(socket, false, port, false);

	if (socket < 0) {
		throw "Could not create server";
	}
	
	return socket;
}

function _nwHttp2Connect(ip, port){	
	global._nwHttp2SocketType = 0;
	global._nwHttpAsyncLoad = ds_map_create();
	global._nwHttpClientConnected = false;
	
	var socket = socket_create();
	var res = socket_connect(socket, ip, port);
	
	if (res < 0) {
		throw "The server is offline";
	}
	
	return socket;
}

function _nwHttp2Receive(buffer) {
	hbuffer_set_pos(buffer, 0);
	var msgId = hbuffer_read_uint8(buffer);
	var b64 = hbuffer_read_string(buffer);
	var json = base64_decode(b64);
	var obj = json_parse(json);
	return { id: msgId, data: obj };
}

function _nwHttp2Send(buffer, socket, msgId, package) {
	hbuffer_clear(buffer);
	hbuffer_set_pos(buffer, 0);
	var json = json_stringify(package);
	var b64 = base64_encode(json);
	hbuffer_write_uint8(buffer, msgId);
	hbuffer_write_string(buffer, b64);
	
	socket_write_message(socket, buffer);
}
*/