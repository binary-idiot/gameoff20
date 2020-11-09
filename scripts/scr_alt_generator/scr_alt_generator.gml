enum AreaSides{
	top,
	right,
	bottom,
	left
}

function Point(_x, _y) constructor{
	x = _x;
	y = _y;
}

function createAreaData(_num, _point1, _point2){
	var areas = ds_list_create();
	
	return {
		num : _num,
		point1 : _point1,
		point2 : _point2,
		connectedAreas : areas,
		addConnectedArea : function(_connectedArea){
			ds_list_add(connectedAreas, _connectedArea);	
		}
	}
}

function ds_grid_set_rectangle(grid, x1, y1, x2, y2, val) {
    for (var i = x1; i <= x2; ++i) {
        for (var j = y1; j <= y2; ++j) {
            grid[# i, j] = val;
        }
    }
}

function generateMap(){
	randomize();
	//random_set_seed(2);
	show_debug_message("Seed: "+ string(random_get_seed()));
	//Values for tiles
	wall = -1;
	door = -2;
	areaNum = 0;
	
	//Parameters
	var minArea = 25, maxArea = 100;
	var width = irandom_range(minArea, maxArea);
	var length = irandom_range(minArea, maxArea);
	
	var minAreaSize = 8
	var maxAreaSize = min(25, round(min(width, length)/2));
	//var mergeAreaSize = round((minAreaSize*maxAreaSize)/2);
	
	var map = createBSPGrid(width, length, minAreaSize, maxAreaSize);
	
	mergeAreas(map, minAreaSize);
	
	//Check if area is merged by finding corners of area then checking one over each side to see if area is surrounded by walls, 
	//if cell is not a wall that cell belongs to a merged area
	
	var areas = findAreas(map);
	
	return {
		map : map,
		//areas : areas
	};
}


function createBSPGrid(width, length, minAreaSize, maxAreaSize){	
	//Setup data structures
	var grid = ds_grid_create(width, length);
	
	//Set everything to walls
	ds_grid_set_rectangle(grid, 0, 0, width-1, length-1, wall);
	
	//Assign cords for area
	var x1 = 1, y1 = 1;
	var x2 = width - 2, y2 = length - 2;
	
	//Assign area
	ds_grid_set_rectangle(grid, x1, y1, x2, y2, areaNum);
	
	leaf(grid, x1, y1, x2, y2, minAreaSize, maxAreaSize);
	
	return grid;
}

function leaf(grid, x1, y1, x2, y2, minAreaSize, maxAreaSize, dir){
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
		
			ds_grid_set_rectangle(grid, x1, y1, x2, hSplit - 1, areaNum);
			leaf(grid, x1, y1, x2, hSplit - 1, minAreaSize, maxAreaSize);
			areaNum++;
		
			ds_grid_set_rectangle(grid, x1, hSplit + 1, x2, y2, areaNum);
			leaf(grid, x1, hSplit + 1, x2, y2, minAreaSize, maxAreaSize);
		
			ds_grid_set_rectangle(grid, x1, hSplit, x2, hSplit, wall);
		}else{
			leafFailed = true;
		}
		
	}else{
		
		if(!(x1 + size >= x2 - size)){
			var vSplit = irandom_range(x1 + oSize , x2 - oSize);
		
			ds_grid_set_rectangle(grid, x1, y1, vSplit - 1, y2, areaNum);
			leaf(grid, x1, y1, vSplit - 1, y2, minAreaSize, maxAreaSize);
			areaNum++;
		
			ds_grid_set_rectangle(grid, vSplit + 1, y1, x2, y2, areaNum);
			leaf(grid, vSplit + 1, y1, x2, y2, minAreaSize, maxAreaSize);
		
			ds_grid_set_rectangle(grid, vSplit, y1, vSplit, y2, wall);
		}else{
			leafFailed = true;	
		}
	}
	
	if(leafFailed && is_undefined(dir)) leaf(grid, x1, y1, x2, y2, minAreaSize, maxAreaSize, !horiz);
}
	
function mergeAreas(map, minAreaSize){
	var merges = irandom_range(floor(areaNum/6), areaNum - ceil(areaNum/6));
	var completedMerges = 0;
	var usedAreas = ds_list_create();
	
	var mapWidth = ds_grid_width(map) - 1, mapLength = ds_grid_height(map) - 1;
	
	while(merges > completedMerges && areaNum > ds_list_size(usedAreas)){
	//Choose num of random area
		var area = irandom_range(0, areaNum);
			
		//Check if area was already computed
		if(ds_list_find_index(map, area) != -1){ continue;}
		ds_list_add(usedAreas, area);
			
		if(ds_grid_value_exists(map, 0, 0, mapWidth, mapLength, area)){
			//Find top left corner of area
			var x1 = ds_grid_value_x(map, 0, 0, mapWidth, mapLength, area);
			var y1 = ds_grid_value_y(map, 0, 0, mapWidth, mapLength, area);
			var x2 = x1, y2 = y1;
				
			//Find bottom right edges by stepping through until a num diffrent from area is found
			do{x2++;}until(ds_grid_get(map, x2, y1) != area);
			do{y2++;}until(ds_grid_get(map, x1, y2) != area);
			x2--; 
			y2--;
				
			//Determine what sides can be merged
			var sides = ds_list_create();
			if(x1 != 1) ds_list_add(sides, AreaSides.left);
			if(y1 != 1) ds_list_add(sides, AreaSides.top);
			if(x2 != mapWidth - 1) ds_list_add(sides, AreaSides.right);
			if(y2 != mapLength - 1) ds_list_add(sides, AreaSides.bottom);
				
			var mergeSuccessful = false;
				
			do{
				//Choose side to be merged and determine offset to other area
				var side = ds_list_find_value(sides, irandom_range(0, ds_list_size(sides)-1));
				ds_list_delete(sides,ds_list_find_index(sides, side));
				
				
				var offset = (side == AreaSides.top || side == AreaSides.left) ? -2 : 2;
				
				var mergePoints = ds_list_create(); //Store the points on the wall to merge
				
				var sideAttempts = 0;
				
				if(area == 5){
					ds_list_find_index(mergePoints, area);
				}
				
				do{
					ds_list_clear(mergePoints);
					var mergeX, mergeY;
					
					//Choose point on side to start merge
					switch(side){
						case AreaSides.top:
							mergeX = irandom_range(x1+1, x2-1);
							mergeY = y1;
							break;
						case AreaSides.right:
							mergeX = x2;
							mergeY = irandom_range(y1+1, y2-1);
							break;
						case AreaSides.bottom:
							mergeX = irandom_range(x1+1, x2-1);
							mergeY = x2;
						case AreaSides.left:
							mergeX = x1;
							mergeY = irandom_range(y1+1, y2-1);
							break;
							
					}
					
					//Check in both directions until perpendicular wall is reached on either side
					if(side == AreaSides.top || side == AreaSides.bottom){
						var otherRoom = ds_grid_get(map, mergeX, mergeY + offset);
						
						if(otherRoom != wall && ds_list_find_index(usedAreas, otherRoom) == -1){
						
							//Add points at and above merge point until wall is reached
							for(var _x = mergeX; _x >= x1; _x--){
								if(ds_grid_get(map, _x, mergeY + offset) == wall) break;
								ds_list_add(mergePoints, new Point(_x, mergeY + (offset/2)));
							}
						
							for(var _x = mergeX + 1; _x <= x2; _x++){
								if(ds_grid_get(map, _x, mergeY + offset) == wall) break;
								ds_list_add(mergePoints, new Point(_x, mergeY + (offset/2)));
							}
						}else{
							sideAttempts++;	
						}
					}else{
						var otherRoom = ds_grid_get(map, mergeX + offset, mergeY);
						
						if(otherRoom != wall && ds_list_find_index(usedAreas, otherRoom) == -1){
							for(var _y = mergeY; _y >= y1; _y--){
								if(ds_grid_get(map, mergeX + offset, _y) == wall) break;
								ds_list_add(mergePoints, new Point(mergeX + (offset/2), _y));	
							}
						
							for(var _y = mergeY + 1; _y <= y2; _y++){
								if(ds_grid_get(map, mergeX + offset, _y) == wall) break;
								ds_list_add(mergePoints, new Point(mergeX + (offset/2), _y));	
							}
						}else{
							sideAttempts++;	
						}
					}
						
					if(ds_list_size(mergePoints) >= minAreaSize) mergeSuccessful = true;
				
				}until(mergeSuccessful || sideAttempts >= 10);
					
			}until(mergeSuccessful || ds_list_size(sides) <= 0);
				
			//Change sepparating wall to be nom of the area being computed
			for(var i = 0; i < ds_list_size(mergePoints); i++){
				ds_grid_set(map, mergePoints[| i].x, mergePoints[| i].y, area);
			}
				
			if(mergeSuccessful) completedMerges++;
				
		}
	}
}


function findAreas(map){
	var areas = ds_list_create();
		
	var mapWidth = ds_grid_width(map) - 1, mapLength = ds_grid_height(map) - 1;
		
	for(var area = 0; area <= areaNum; area++){
		var x1 = ds_grid_value_x(map, 0, 0, mapWidth, mapLength, area);
		var y1 = ds_grid_value_y(map, 0, 0, mapWidth, mapLength, area);
			
		var x2 = x1, y2 = y1;
		do{x2++;}until(ds_grid_get(map, x2, y1) != area);
		do{y2++;}until(ds_grid_get(map, x1, y2) != area);
		x2--; 
		y2--;
			
		var areaData = createAreaData(area, new Point(x1, y1), new Point(x2, y2));
			
		if(x1 != 1){
			for(var _y = y1; _y <= y2; _y++){
				var otherArea = ds_grid_get(map, x1 - 1, _y);
				if(otherArea == area){
					var otherArea = ds_grid_get(map, x1 - 2, _y);	
				}
				if(otherArea != wall && ds_list_find_index(areaData.connectedAreas, otherArea) == -1){
					areaData.addConnectedArea(otherArea);
				}
			}
		}
			
		if(x1 != mapWidth - 1){
			for(var _y = y1; _y <= y2; _y++){
				var otherArea = ds_grid_get(map, x2 + 1, _y);
				if(otherArea == area){
					var otherArea = ds_grid_get(map, x2 + 2, _y);	
				}
				if(otherArea != wall && ds_list_find_index(areaData.connectedAreas, otherArea) == -1){
					areaData.addConnectedArea(otherArea);
				}
			}
		}
			
		if(y1 != 1){
			for(var _x = x1; _x <= x2; _x++){
				var otherArea = ds_grid_get(map, _x, y1 - 1);
				if(otherArea == area){
					var otherArea = ds_grid_get(map, _x, y1 - 2);	
				}
				if(otherArea != wall && ds_list_find_index(areaData.connectedAreas, otherArea) == -1){
					areaData.addConnectedArea(otherArea);
				}
			}
		}
			
		if(y1 != mapLength -1){
			for(var _x = x1; _x <= x2; _x++){
				var otherArea = ds_grid_get(map, _x, y2 + 1);
				if(otherArea == area){
					var otherArea = ds_grid_get(map, _x, y2 + 2);	
				}
				if(otherArea != wall && ds_list_find_index(areaData.connectedAreas, otherArea) == -1){
					areaData.addConnectedArea(otherArea);
				}
			}
		}
		
		ds_list_add(areas, areaData);
			
	}
	
	return areas;
	
}