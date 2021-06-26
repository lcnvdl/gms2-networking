if(nw_is_server() && !instance_exists(nw_global_score)) {
	instance_create_layer(0, 0, "Instances", nw_global_score);
}
