if (isPlayer) {
	var _uuid = nw_add_sender(id, undefined);
	var sender = nw_get_sender(_uuid);
	
	//	Controlled by server
	sender.AddSyncVarNumber("hp", 0.1).SetBinding(SyncVarBinding.Server);
	sender.AddSyncVarText("lastCommandBy").SetBinding(SyncVarBinding.Server);

	//	Bidirectional (is not working fine)
	sender.AddSyncVarNumber("xTarget", 0.1).SetBinding(SyncVarBinding.TwoWay);
	sender.AddSyncVarNumber("yTarget", 0.1).SetBinding(SyncVarBinding.TwoWay);
	
	//	Controlled by client
	sender.AddSyncVarText("name");
}
