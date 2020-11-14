if(cycleDir == 1){
	isOpen = true;
	cycleDir = 0;
	alarm[0] = openDuration * room_speed;
}else if(cycleDir == -1){
	cycleDir = 0;
}