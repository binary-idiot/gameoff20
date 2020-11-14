
if(cycleDir == 1 && image_index == image_number-1){
		isOpen = true;
		cycleDir = 0;
		image_speed = 0;
		alarm[0] = openDuration * room_speed;
}else if(cycleDir == -1 && image_index == 0){
	cycleDir = 0;
	image_speed = 0;
}else if(cycleDir != 0){
	image_speed = (cycleSpeed * cycleDir) / room_speed;	
}