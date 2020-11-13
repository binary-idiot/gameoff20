image_index = 0;
image_speed = 0;

isOpen = false;
openTimer = 1;

if(!instance_exists(obj_door_helper)){
	instance_create_layer(0, 0, "Instances_lower", obj_door_helper);	
}