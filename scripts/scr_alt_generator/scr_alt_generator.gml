
function scr_alt_generator(){
	randomize();
	//Values for tiles
	wall = -1;
	door = -2;
	areaNum = 0;
	
	//Parameters
	var minRoom = 25, maxRoom = 100;
	var width = irandom_range(minRoom, maxRoom);
	var length = irandom_range(minRoom, maxRoom);
	minAreaSize = 8
	maxAreaSize = min(25, round(min(width, length)/2));
	
	//Setup data structures
	grid = ds_grid_create(width, length);
	list = ds_list_create();
	
	//Set everything to walls
	ds_grid_set_region(grid, 0, 0, width-1, length-1, wall);
	
	//Assign cords for area
	var x1 = 1, y1 = 1;
	var x2 = width - 2, y2 = length - 2;
	
	//Assign area
	ds_grid_set_region(grid, x1, y1, x2, y2, areaNum);
	
	leaf(x1, y1, x2, y2);
	
	return grid;
}

function leaf(x1, y1, x2, y2, dir){
	var leafFailed = false;
	var horiz;
	var size = irandom_range(minAreaSize, maxAreaSize);
	var oSize = size;
	
	if(is_undefined(dir)){
		horiz = choose(true, false);
	}else{
		horiz = dir;
	}
	
	
	if(horiz){
		
		if(!(y1 + size >= y2 - size)){
			var hSplit = irandom_range(y1 + oSize , y2 - oSize);
		
			ds_grid_set_region(grid, x1, y1, x2, hSplit - 1, areaNum);
			leaf(x1, y1, x2, hSplit - 1);
			areaNum++;
		
			ds_grid_set_region(grid, x1, hSplit + 1, x2, y2, areaNum);
			leaf(x1, hSplit + 1, x2, y2);
		
			ds_grid_set_region(grid, x1, hSplit, x2, hSplit, wall);
		}else{
			leafFailed = true;
		}
		
	}else{
		
		if(!(x1 + size >= x2 - size)){
			var vSplit = irandom_range(x1 + oSize , x2 - oSize);
		
			ds_grid_set_region(grid, x1, y1, vSplit - 1, y2, areaNum);
			leaf(x1, y1, vSplit - 1, y2);
			areaNum++;
		
			ds_grid_set_region(grid, vSplit + 1, y1, x2, y2, areaNum);
			leaf(vSplit + 1, y1, x2, y2);
		
			ds_grid_set_region(grid, vSplit, y1, vSplit, y2, wall);
		}else{
			leafFailed = true;	
		}
	}
	
	if(leafFailed && is_undefined(dir)) leaf(x1, y1, x2, y2, !horiz);
}