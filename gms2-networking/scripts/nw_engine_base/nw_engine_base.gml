/*
	Base Networking Engine.
	
	Replace all the members with functions.

	function get<EngineName>NetworkEngine() {
		return {
			serve: function(port) { return -1 },		//	Starts as a server.
			connect: function(ip, port) { return -1 },	//	Starts as a client.
			receive: function(buffer) {					//	Receives a message.
				return { id, data };
			},
			send: function(buffer,						//	Sends a message.
				socket, 
				msgId, 
				package) {},							
			destroySocket: function(socketId) {},		//	Releases a socket.
			createBuffer: function(bufferSize,			//	Creates a buffer.
				bufferType, 
				alignment) { return -1; },								
			destroyBuffer: function(bufferId) {},		//	Destroys an existing buffer.
			evStep: undefined,							//	Optional
			evAsync: undefined							//	Optional
		};
	}
*/