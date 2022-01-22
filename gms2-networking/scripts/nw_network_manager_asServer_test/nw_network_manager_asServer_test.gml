function nw_networkManager_test() : GMLTest_Harness() constructor {
	entity = pointer_null;
	//asyncLoad = pointer_null;
	
	function setup() {
		global.nwNetworkManagerFactory = function() { 
			global.testMock = getMockNetworkEngine(); 
			return global.testMock;
		};
		
		entity = instance_create_depth(0, 0, 0, nw_network_manager);
		
		global.nwNetworkManager = entity;
		
		//asyncLoad = ds_map_create();
	}
	
	function tear_down() {
		//ds_map_destroy(asyncLoad);
		instance_destroy(entity);
	}
}

test_f(nw_networkManager_test, "nw_network_manager startServer should work", function() {
	var socket = entity.startServer();
	gmltest_expect_true(socket >= 0);
	gmltest_expect_true(nw_is_server());	
	gmltest_expect_false(nw_is_client());
	gmltest_expect_true(nw_is_online());
});

test_f(nw_networkManager_test, "_onReceiveServerPacket syncClientLocationCreate should work", function() {
	var socket = entity.startServer();
	var clientSocket = global._mockNetworkEngine.newSocket(1234);
		
	entity._addNewClient(clientSocket);
	entity.evCallWithArgs(EV_SOCKET_CONNECT, { socket: clientSocket });
	
	var pck = {
		id: NwMessageType.syncClientLocationCreate,
		data: {
			X: 1,
			Y: 1,
			Range: 100,
			Name: "Default"
		}
	};
	
	entity.protocol.serverProtocol(entity, pck, clientSocket);
	
	var sent = array_length(global._mockNetworkEngine.sent);

	gmltest_expect_eq(1, sent);
	
	var pck = global._mockNetworkEngine.sent[0].package;

	gmltest_expect_true(pck.success);
});


test_f(nw_networkManager_test, "_onReceiveServerPacket syncClientLocationUpdate should fail if the watcher is not created", function() {
	var socket = entity.startServer();
	var clientSocket = global._mockNetworkEngine.newSocket(1234);
		
	entity._addNewClient(clientSocket);
	entity.evCallWithArgs(EV_SOCKET_CONNECT, { socket: clientSocket });
	
	var pck = {
		id: NwMessageType.syncClientLocationUpdate,
		data: {
			X: 1,
			Y: 1,
			Name: "Main",
		}
	};
	
	entity.protocol.serverProtocol(entity, pck, clientSocket);
	
	var sent = array_length(global._mockNetworkEngine.sent);

	gmltest_expect_eq(1, sent);
	
	var pck = global._mockNetworkEngine.sent[0].package;

	gmltest_expect_false(pck.success);
});
