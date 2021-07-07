/**
* @file Auto-Communication API.
* @author Forja Games <forjagames.com@gmail.com>
* @license MIT
*/

/// @function nw_add_sender(instance, _uuid, *opts)
/// @description 	Registers a game object as a Sender. A Sender it is an instance 
///					responsible to replicate its values to the Receivers. 
///					When a Sender is created, the system creates a Receiver 
///					instance in each network node. The Receivers receive
///					information from the senders, like the Position (x, y), the
///					image_angle, etc.  You can add more synchronization variables.
///					Default synchronized variables: 
///						x, y, image_alpha, image_angle, image_single
/// @param {instance} instance - Instance ID.
/// @param {string|undefined} _uuid - UUID. If it is undefined, an unique UUID is automatically generated.
/// @param {*} [opts] - Custom settings.
/// @return {string} Final UUID.
function nw_add_sender(instance, _uuid) {
	assert_is_true(instance_exists(instance));
	return global.nwNetworkManager.nwRegisterObjectAsSyncSender(instance, _uuid, argument_count > 2 ? argument[2] : undefined);
}

/// @function nw_add_empty_sender(instance, _uuid)
/// @description 	Registers a game object as a Sender. The empty sender has no 
///					synchronization variables by default. You can add more 
///					synchronized values.
/// @param {instance} instance - Instance ID.
/// @param {string|undefined} _uuid - UUID. If it is undefined, an unique UUID is automatically generated.
/// @return {string} Final UUID.
function nw_add_empty_sender(instance, _uuid) {
	assert_is_true(instance_exists(instance));
	var _opts = { 
		emptySender: true 
	};
	return global.nwNetworkManager.nwRegisterObjectAsSyncSender(instance, _uuid, _opts);
}

/// @function nw_singleton_receiver(instance, _uuid)
/// @description 	Registers a game object as a Singleton Receiver. The singleton 
///					receiver is useful for specific cases when you need to manually 
///					manage the instantiation of the receivers.
/// @param {instance} instance - Instance ID.
/// @param {string|undefined} _uuid - UUID. If it is undefined, an unique UUID is automatically generated.
/// @return {string} Final UUID.
function nw_singleton_receiver(instance, _uuid) {
	assert_is_string(_uuid);
	assert_is_true(instance_exists(instance));
	instance.nwUuid = _uuid;
	return _uuid;
}

/// @function nw_get_senders_mgr()
/// @description Returns the instance of the senders manager.
/// @return {SendersManager} Senders manager.
function nw_get_senders_mgr() {
	return global.nwNetworkManager.getSendersManager();	
}

/// @function nw_get_sender(instanceUuid)
/// @description Gets a specific sender.
/// @param {string} instanceUuid - Instance UUID.
/// @return {Sender|undefined} Sender.
function nw_get_sender(instanceUuid) {
	//	assert_is_string(instanceUuid);	//	Commented in order to improve performance
	return global.nwNetworkManager.getSendersManager().Get(instanceUuid);
}

/// @function nw_sender_exists(instanceUuid)
/// @description Checks if the sender exists.
/// @param {string} instanceUuid - Instance UUID.
/// @return {boolean} True or false.
function nw_sender_exists(instanceUuid) {
	return global.nwNetworkManager.getSendersManager().Exists(instanceUuid);
}

/// @function nw_instance_get_uuid(instance)
/// @description Gets the UUID of a Network Instance.
/// @param {instance} instance - Instance ID.
/// @return {string} UUID.
function nw_instance_get_uuid(instance) {
	return instance.nwUuid;	
}

/// @function nw_get_instance(instanceUuid)
/// @description Gets the UUID of a Network Instance.
/// @param {string} instanceUuid - Instance UUID.
/// @return {string} UUID.
function nw_get_instance(instanceUuid) {
	var _uuid = instanceUuid;
	var existing = undefined;
	
	with(all) {
		if(variable_instance_exists(id, "nwUuid")) {
			if(nwUuid == _uuid) {
				existing = id;	
			}
		}
	}
	
	return existing;
}