//	Sockets
if (!is_undefined(engine)) {
	engine.destroyBuffer(sendBuffer);
	engine.destroySocket(serverSocket);
}

//	Server controller
if (!is_undefined(_serverController)) {
	_serverController.Dispose();	
}

//	Senders and receivers
_sendersMgr.Dispose();
_receiversMgr.Dispose();

//	Clients (connections)
_clientsMgr.Dispose();

//	Events
cleanUpSubscriptions();

//	Finish
offline = true;
