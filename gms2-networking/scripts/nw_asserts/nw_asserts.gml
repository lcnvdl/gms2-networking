function nw_assert_is_receiver(instanceIndex) {
	assert_is_true(nw_instance_is_receiver(instanceIndex), "The instance must be a Receiver");	
}

function nw_assert_is_sender(instanceIndex) {
	assert_is_true(nw_instance_is_sender(instanceIndex), "The instance must be a Sender");	
}