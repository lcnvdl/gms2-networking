//	Sockets
if (!is_undefined(engine)) {
	engine.destroyBuffer(sendBuffer);
	engine.destroySocket(serverSocket);
}

//	Senders and receivers
_sendersMgr.Dispose();
_receiversMgr.Dispose();

//	Clients (connections)
_clientsMgr.Dispose();

//	Events
cleanUpSubscriptions();
