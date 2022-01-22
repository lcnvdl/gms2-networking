function getMockNetworkEngine() {
	global._mockNetworkEngine = {
		currentSocket: 0,
		sockets: [],
		sent: [],
		recv: [],
		newSocket: function(port, _serverIp) {
			var current = global._mockNetworkEngine.currentSocket++;
			global._mockNetworkEngine.sockets[current] = {
				sid: current,
				serverIp: _serverIp,
				ip: "127.0.0.1",
				port: port
			};
			return current;
		}
	};
	
	return {
		serve: _nwMockServe,
		connect: _nwMockConnect,
		receive: _nwMockReceive,
		send: _nwMockSend,
		destroySocket: _nwMockDestroySocket,
		createBuffer: _nwMockCreateBuffer,
		destroyBuffer: _nwMockDestroyBuffer,
		evStep: undefined,
		evAsync: undefined
	};
}

function _nwMockCreateBuffer(bufferSize, bufferType, alignment) {
	return buffer_create(bufferSize, bufferType, alignment);
}

function _nwMockDestroyBuffer(bufferId) {
	buffer_delete(bufferId);
}

function _nwMockDestroySocket(socketId) {
	global._mockNetworkEngine[socketId] = undefined;
}

function _nwMockServe(port){
	var socket = global._mockNetworkEngine.newSocket(port, undefined);
	
	if (socket < 0) {
		throw "Could not create server";
	}
	
	return socket;
}

function _nwMockConnect(ip, port){	
	var socket = global._mockNetworkEngine.newSocket(port, ip);
	
	if (socket < 0) {
		throw "The server is offline";
	}
	
	return socket;
}

function _nwMockReceive(buffer) {
	buffer_seek(buffer, buffer_seek_start, 0);
	var msgId = buffer_read(buffer, buffer_u8);
	var b64 = buffer_read(buffer, buffer_string);
	var json = base64_decode(b64);
	var obj = json_parse(json);
	var pck = { id: msgId, data: obj };
	
	array_push(global._mockNetworkEngine.recv, { package: pck, buffer: buffer });
	
	return pck;
}

function _nwMockSend(buffer, socket, msgId, package) {
	buffer_seek(buffer, buffer_seek_start, 0);
	var json = json_stringify(package);
	var b64 = base64_encode(json);
	buffer_write(buffer, buffer_u8, msgId);
	buffer_write(buffer, buffer_string, b64);
	
	array_push(global._mockNetworkEngine.sent, { package: package, buffer: buffer });
	// network_send_packet(socket, buffer, buffer_tell(buffer));
}



