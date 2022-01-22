function getProtocolV1() {
	return {
		clientProtocol: function(_self, _pck) {
			var pck = _pck;
			with(_self) {
				if (pck.id == NwMessageType.syncPackage) {
					var _socket = global.nwNetworkManager.serverSocket;
					var _eventPackage = pck.data;
					self.evCallWithArgs("recv-" + _eventPackage.name, { socket: _socket, data: _eventPackage.data });
				}
				else if (pck.id == NwMessageType.syncObjectCreate) {
				}
				else if (pck.id == NwMessageType.syncClientLocationCreate) {
					var _eventPackage = pck.data;
					if(autoSendWatchPoint == 0 && _eventPackage.data.name == "nwCamera") {
						if (_eventPackage.data.success) {
							autoSendWatchPoint = 1;	
						}
						else {
							autoSendWatchPoint = -1;	
						}
					}
					//var _socket = global.nwNetworkManager.serverSocket;
					//var _eventPackage = pck.data;
					//self.evCallWithArgs("recv-" + _eventPackage.name, { socket: _socket, data: _eventPackage.data });
				}
				else if (pck.id == NwMessageType.syncClientLocationUpdate) {
					var _eventPackage = pck.data;
					if(autoSendWatchPoint == 1 && _eventPackage.data.name == "nwCamera" && !_eventPackage.data.success) {
						autoSendWatchPoint = -1;	
					}
					//var _socket = global.nwNetworkManager.serverSocket;
					//var _eventPackage = pck.data;
					//self.evCallWithArgs("recv-" + _eventPackage.name, { socket: _socket, data: _eventPackage.data });
				}
				else if (pck.id == NwMessageType.rpcReceiverFunctionCallFindSender) {
					_rpcMgr.FindSenderAndReply(pck.data);
				}
				else if (pck.id == NwMessageType.rpcSenderBroadcastCall) {
					_rpcMgr.BroadcastCall(pck.data);
				}
				else if (pck.id == NwMessageType.rpcSenderFunctionReply) {
					_rpcMgr.ReceiveReply(pck.data);
				}
				else if (pck.id == NwMessageType.rpcReceiverFunctionReply) {
					_rpcMgr.ReceiveReply(pck.data);
				}
				else if (pck.id == NwMessageType.syncObjectDelete) {
					_receiversMgr.DestroyAndDelete(pck.data.uuid);
				}
				else if (pck.id == NwMessageType.syncObjectUpdate)  {
					if(!_sendersMgr.Exists(pck.data.uuid)) {
						_receiversMgr.ReceiveDataFromSender(pck.data, undefined);
					}
				}
			}
		},
		
		serverProtocol: function(_self, _pck, _socket) {
			var socket = _socket;
			var pck = _pck;
			
			with(_self) {
				if (pck.id == NwMessageType.syncPackage) {
					var _eventPackage = pck.data;
					self.evCallWithArgs("recv-" + _eventPackage.name, { socket: socket, data: _eventPackage.data });
				}
				else if (pck.id == NwMessageType.syncObjectCreate) {
				}
				else if (pck.id == NwMessageType.rpcSenderBroadcastCall) {
					_rpcMgr.BroadcastCall(pck.data);
				}
				else if (pck.id == NwMessageType.rpcSenderBroadcastReplicate) {
					_rpcMgr.BroadcastCall(pck.data);
					_rpcMgr.BroadcastReplicate(pck.data, socket);
				}
				else if (pck.id == NwMessageType.rpcReceiverFunctionCall) {
					//	Receiver (client or server) calls to Sender (server or client)
					_rpcMgr.ReceiverCallToSender(pck.data, socket);
				}
				else if (pck.id == NwMessageType.rpcReceiverFunctionReply) {
					_rpcMgr.ReceiveReply(pck.data);
				}
				else if (pck.id == NwMessageType.rpcSenderFunctionCall) {
					//	Sender (client) calls to receiver (server)
					_rpcMgr.SenderCallToReceiver(pck.data, socket);
				}
				else if (pck.id == NwMessageType.syncClientLocationCreate) {
					var info = self._clientsMgr.GetInfo(socket);
					var wp = info.GetWatchPoint(pck.data.Name);
					if (is_undefined(wp)) {
						info.AddWatchPoint(pck.data.Name, pck.data.X, pck.data.Y, pck.data.Range);
					}
					nwCustomSend(socket, pck.id, { success: true, name: pck.data.Name });
				}
				else if (pck.id == NwMessageType.syncClientLocationUpdate) {
					var info = _clientsMgr.GetInfo(socket);
					var wp = info.GetWatchPoint(pck.data.Name);
					if (is_undefined(wp)) {
						nwCustomSend(socket, pck.id, { success: false, name: pck.data.Name });
					}
					else {
						wp.X = pck.data.X;
						wp.Y = pck.data.Y;
						nwCustomSend(socket, pck.id, { success: true, name: pck.data.Name });
					}
				}
				else if (pck.id == NwMessageType.syncObjectDelete) {
					_receiversMgr.DestroyAndDelete(pck.data.uuid);
					nwBroadcast(pck.id, pck.data);	
				}
				else if (pck.id == NwMessageType.syncObjectUpdate)  {
					if(!_sendersMgr.Exists(pck.data.uuid)) {
						_receiversMgr.ReceiveDataFromSender(pck.data, socket);
						//	TODO	Validate data
						nwBroadcast(pck.id, pck.data);
					}
					else {
						//	TODO	Update senders
					}
				}
			}
		}
	};
}




