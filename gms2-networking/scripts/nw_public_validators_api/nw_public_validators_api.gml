/**
* @file Server-Side Validators API.
* @author Forja Games <forjagames.com@gmail.com>
* @license MIT
*/

function nw_server_register_validator(objectIndex, fn) {
	global.nwNetworkManager.getServerController().RegisterValidator(objectIndex, fn);
}

function nw_server_unregister_validator(objectIndex) {
	global.nwNetworkManager.getServerController().UnregisterValidator(objectIndex);
}

function nw_server_clear_validators() {
	global.nwNetworkManager.getServerController().ClearValidators();
}
