/*
function generateLevel(){
	var width = 5, length = 10;
	
	var grid = ds_grid_create(width, length); //Grid of room ids representing completed map
	var roomList = ds_list_create(); //Stores all rooms as theyre created
	var roomStack = ds_stack_create(); //The 
	
	//Choose start cell on edge
	var startX, startY;
	
	startX = choose(0, width, irandom_range(0, width));
	if(startX == 0 || startX == width){
		startY = irandom_range(0, length);	
	}else{
		startY = choose(0, length);	
	}
	
	var roomId = addRoom(roomList, startX, startY, 1, 1);
	ds_grid_add(grid, startX, startY, roomId);
	
	//Choose cell on edge of
	
	
}


function addRoom(_list, _x, _y, _width, _length){
	var idNum = ds_list_size(_list);
	ds_list_add(_list, new Room(idNum, _x, _y, _width, _length));
	return idNum;
}

/*
function choosePointOnEdge(_x, _y, _width, _length){
	
}

function addRoomToGrid(_roomId, )


Room = function(_id, _x, _y, _width, _length) constructor{
	roomID = _id;
	x = _x;
	y = _y;
	width = _width;
	length = _length;
	type = undefined;
}

*/
Point = function(_x, _y) constructor{
	x = _x;
	y = _y;
}