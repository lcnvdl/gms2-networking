function nw_receiver_test() : GMLTest_Harness() constructor {
	receiver = pointer_null;
	
	function setup() {
		receiver = new nw_Receiver();
		receiver.uuid = getUuid();
	}
	
	function tear_down() {
		receiver.Dispose();
	}
}

test_f(nw_receiver_test, "nw_receiver GetSyncVar should return undefined if doesn't exists", function() {
	var result = receiver.GetSyncVar("var");
	gmltest_expect_true(is_undefined(result));
});

