//	Sockets
engine.destroyBuffer(sendBuffer);
engine.destroySocket(serverSocket);

//	Senders and receivers
_sendersMgr.Dispose();

ds_map_foreach(senders, function(sender) {
	sender.Dispose();
}, undefined);
ds_map_destroy(senders);
	
ds_map_foreach(receivers, function(v, k) {
	ds_list_destroy(v.syncVariables);
}, undefined);
ds_map_destroy(receivers);
	
ds_list_destroy(clients);
ds_map_destroy(clientsInfo);

//	Events
cleanUpSubscriptions();
