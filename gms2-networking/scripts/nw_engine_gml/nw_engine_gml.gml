function getGmlNetworkEngine() {
	return {
		serve: _nwGmlServe,
		connect: _nwGmlConnect,
		receive: _nwGmlReceive,
		send: _nwGmlSend,
		destroySocket: _nwGmlDestroySocket,
		createBuffer: _nwGmlCreateBuffer,
		destroyBuffer: _nwGmlDestroyBuffer,
		evStep: undefined,
		evAsync: undefined
	};
}

function _nwGmlCreateBuffer(bufferSize, bufferType, alignment) {
	return buffer_create(bufferSize, bufferType, alignment);
}

function _nwGmlDestroyBuffer(bufferId) {
	buffer_delete(bufferId);
}

function _nwGmlDestroySocket(socketId) {
	network_destroy(socketId);
}

function _nwGmlServe(port){
	var socket = network_create_server(network_socket_tcp, port, 99);
	
	if (socket < 0) {
		throw "Could not create server";
	}
	
	return socket;
}

function _nwGmlConnect(ip, port){	
	var socket = network_create_socket(network_socket_tcp);
	var res = network_connect(socket, ip, port);
	
	if (res < 0) {
		throw "The server is offline";
	}
	
	return socket;
}

function _nwGmlReceive(buffer) {
	buffer_seek(buffer, buffer_seek_start, 0);
	var msgId = buffer_read(buffer, buffer_u8);
	var b64 = buffer_read(buffer, buffer_string);
	var json = base64_decode(b64);
	var obj = json_parse(json);
	return { id: msgId, data: obj };
}

function _nwGmlSend(buffer, socket, msgId, package) {
	buffer_seek(buffer, buffer_seek_start, 0);
	var json = json_stringify(package);
	var b64 = base64_encode(json);
	buffer_write(buffer, buffer_u8, msgId);
	buffer_write(buffer, buffer_string, b64);
	network_send_packet(socket, buffer, buffer_tell(buffer));
}



