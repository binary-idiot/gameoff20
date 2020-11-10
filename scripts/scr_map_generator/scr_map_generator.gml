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
	var merged = ds_list_create();
	var conn = ds_list_create();
	var neigh = ds_list_create();
	
	return {
		num : _num,
		point1 : _point1,
		point2 : _point2,
		mergedAreas : merged,
		connectedAreas : conn,
		neighbors : neigh,
		addMergedArea : function(area){
			ds_list_add(mergedAreas, area);
			addConnectedArea(area);
		},
		addConnectedArea : function(area){
			ds_list_add(connectedAreas, area);
		},
		addNeighbor : function(neighbor){
			ds_list_add(neighbors, neighbor);
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
	//Values for tiles
	mapWallTile = -1;
	mapDoorTile = -2;
	mapAreaNum = 0;
	
	//Parameters
	var minArea = 30, maxArea = 50;
	var width = irandom_range(minArea, maxArea);
	var length = irandom_range(minArea, maxArea);
	
	var minAreaSize = 4;
	var maxAreaSize = min(15, round(min(width, length)/2));
	//var mergeAreaSize = round((minAreaSize*maxAreaSize)/2);
	
	var map = createBSPGrid(width, length, minAreaSize, maxAreaSize);
	
	mergeAreas(map, minAreaSize);
	
	var areas = findAreas(map);
	addDoors(map, areas);
	
	return {
		map : map,
		areas : areas
	};
}


function createBSPGrid(width, length, minAreaSize, maxAreaSize){	
	//Setup data structures
	var grid = ds_grid_create(width, length);
	
	//Set everything to mapWallTiles
	ds_grid_set_rectangle(grid, 0, 0, width-1, length-1, mapWallTile);
	
	//Assign cords for area
	var x1 = 1, y1 = 1;
	var x2 = width - 2, y2 = length - 2;
	
	//Assign area
	ds_grid_set_rectangle(grid, x1, y1, x2, y2, mapAreaNum);
	
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
		
			ds_grid_set_rectangle(grid, x1, y1, x2, hSplit - 1, mapAreaNum);
			leaf(grid, x1, y1, x2, hSplit - 1, minAreaSize, maxAreaSize);
			mapAreaNum++;
		
			ds_grid_set_rectangle(grid, x1, hSplit + 1, x2, y2, mapAreaNum);
			leaf(grid, x1, hSplit + 1, x2, y2, minAreaSize, maxAreaSize);
		
			ds_grid_set_rectangle(grid, x1, hSplit, x2, hSplit, mapWallTile);
		}else{
			leafFailed = true;
		}
		
	}else{
		
		if(!(x1 + size >= x2 - size)){
			var vSplit = irandom_range(x1 + oSize , x2 - oSize);
		
			ds_grid_set_rectangle(grid, x1, y1, vSplit - 1, y2, mapAreaNum);
			leaf(grid, x1, y1, vSplit - 1, y2, minAreaSize, maxAreaSize);
			mapAreaNum++;
		
			ds_grid_set_rectangle(grid, vSplit + 1, y1, x2, y2, mapAreaNum);
			leaf(grid, vSplit + 1, y1, x2, y2, minAreaSize, maxAreaSize);
		
			ds_grid_set_rectangle(grid, vSplit, y1, vSplit, y2, mapWallTile);
		}else{
			leafFailed = true;	
		}
	}
	
	if(leafFailed && is_undefined(dir)) leaf(grid, x1, y1, x2, y2, minAreaSize, maxAreaSize, !horiz);
}
	
function mergeAreas(map, minAreaSize){
	var merges = irandom_range(floor(mapAreaNum/6), mapAreaNum - ceil(mapAreaNum/6));
	var completedMerges = 0;
	var usedAreas = ds_list_create();
	
	var mapWidth = ds_grid_width(map) - 1, mapLength = ds_grid_height(map) - 1;
	
	while(merges > completedMerges && mapAreaNum > ds_list_size(usedAreas)){
	//Choose num of random area
		var area = irandom_range(0, mapAreaNum);
			
		//Check if area was already computed
		if(ds_list_find_index(map, area) != -1){ continue;}
		ds_list_add(usedAreas, area);
			
		if(ds_grid_value_exists(map, 0, 0, mapWidth, mapLength, area)){
			//Find top left corner of area
			var x1 = ds_grid_value_x(map, 0, 0, mapWidth, mapLength, area);
			var y1 = ds_grid_value_y(map, 0, 0, mapWidth, mapLength, area);
			var x2 = x1, y2 = y1;
				
			//Find bottom right edges by stepping through until a num diffrent from area is found
			do{x2++;}until(map[# x2, y1] != area);
			do{y2++;}until(map[# x1, y2] != area);
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
				
				var mergePoints = ds_list_create(); //Store the points on the mapWallTile to merge
				
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
					
					//Check in both directions until perpendicular mapWallTile is reached on either side
					if(side == AreaSides.top || side == AreaSides.bottom){
						var otherRoom = ds_grid_get(map, mergeX, mergeY + offset);
						
						if(otherRoom != mapWallTile && ds_list_find_index(usedAreas, otherRoom) == -1){
						
							//Add points at and above merge point until mapWallTile is reached
							for(var _x = mergeX; _x >= x1; _x--){
								if(ds_grid_get(map, _x, mergeY + offset) == mapWallTile) break;
								ds_list_add(mergePoints, new Point(_x, mergeY + (offset/2)));
							}
						
							for(var _x = mergeX + 1; _x <= x2; _x++){
								if(ds_grid_get(map, _x, mergeY + offset) == mapWallTile) break;
								ds_list_add(mergePoints, new Point(_x, mergeY + (offset/2)));
							}
						}else{
							sideAttempts++;	
						}
					}else{
						var otherRoom = ds_grid_get(map, mergeX + offset, mergeY);
						
						if(otherRoom != mapWallTile && ds_list_find_index(usedAreas, otherRoom) == -1){
							for(var _y = mergeY; _y >= y1; _y--){
								if(ds_grid_get(map, mergeX + offset, _y) == mapWallTile) break;
								ds_list_add(mergePoints, new Point(mergeX + (offset/2), _y));	
							}
						
							for(var _y = mergeY + 1; _y <= y2; _y++){
								if(ds_grid_get(map, mergeX + offset, _y) == mapWallTile) break;
								ds_list_add(mergePoints, new Point(mergeX + (offset/2), _y));	
							}
						}else{
							sideAttempts++;	
						}
					}
						
					if(ds_list_size(mergePoints) >= minAreaSize) mergeSuccessful = true;
				
				}until(mergeSuccessful || sideAttempts >= 10);
					
			}until(mergeSuccessful || ds_list_size(sides) <= 0);
				
			//Change sepparating mapWallTile to be nom of the area being computed
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
		
	for(var area = 0; area <= mapAreaNum; area++){
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
				if(otherArea != mapWallTile && ds_list_find_index(areaData.mergedAreas, otherArea) == -1){
					areaData.addMergedArea(otherArea);
				}
			}
		}
			
		if(x1 != mapWidth - 1){
			for(var _y = y1; _y <= y2; _y++){
				var otherArea = ds_grid_get(map, x2 + 1, _y);
				if(otherArea == area){
					var otherArea = ds_grid_get(map, x2 + 2, _y);	
				}
				if(otherArea != mapWallTile && ds_list_find_index(areaData.mergedAreas, otherArea) == -1){
					areaData.addMergedArea(otherArea);
				}
			}
		}
			
		if(y1 != 1){
			for(var _x = x1; _x <= x2; _x++){
				var otherArea = ds_grid_get(map, _x, y1 - 1);
				if(otherArea == area){
					var otherArea = ds_grid_get(map, _x, y1 - 2);	
				}
				if(otherArea != mapWallTile && ds_list_find_index(areaData.mergedAreas, otherArea) == -1){
					areaData.addMergedArea(otherArea);
				}
			}
		}
			
		if(y1 != mapLength -1){
			for(var _x = x1; _x <= x2; _x++){
				var otherArea = ds_grid_get(map, _x, y2 + 1);
				if(otherArea == area){
					var otherArea = ds_grid_get(map, _x, y2 + 2);	
				}
				if(otherArea != mapWallTile && ds_list_find_index(areaData.mergedAreas, otherArea) == -1){
					areaData.addMergedArea(otherArea);
				}
			}
		}
		
		ds_list_add(areas, areaData);
			
	}
	
	areas = findNeighbors(areas);
	
	return areas;
	
}

function findNeighbors(areas){
	for(var i = 0; i < ds_list_size(areas); i++){
		var area = areas[| i];
		for(var j = 0; j <ds_list_size(areas); j++){
			var otherArea = areas[| j];
			if(area.num == otherArea.num) continue;
			if(ds_list_find_index(area.mergedAreas, otherArea.num) != -1){
				area.addNeighbor(otherArea.num);
				continue;
			}
			
			if((area.point1.x > otherArea.point1.x && area.point1.x < otherArea.point2.x) || (area.point1.x < otherArea.point1.x && area.point2.x > otherArea.point1.x) || (area.point1.x == otherArea.point1.x)){
				if(area.point1.y - 2 == otherArea.point2.y || area.point2.y + 2 == otherArea.point1.y){
					area.addNeighbor(otherArea.num);
					continue;
				}else{
					continue;	
				}
					
			} else if((area.point1.y > otherArea.point1.y && area.point1.y < otherArea.point2.y) || (area.point1.y < otherArea.point1.y && area.point2.y > otherArea.point1.y) || (area.point1.y == otherArea.point1.y)){
				if(area.point1.x - 2 == otherArea.point2.x || area.point2.x + 2 == otherArea.point1.x){
					area.addNeighbor(otherArea.num);
					continue;
				}else{
					continue;	
				}
					
			}
		}
	}
	
	return areas;
}
	
function addDoors(map, areas){
		var area = areas[| irandom_range(0, ds_list_size(areas)-1)];
		var visited = ds_list_create();
		
		//Add doors between rooms until all rooms have been visited
		do{
			
			var otherArea;
			var attempts = ds_list_create();
			
			//Randomly select an unconnected neighbor
			do{
				do{

					var n = area.neighbors[| irandom_range(0, ds_list_size(area.neighbors) -1)];
					otherArea = areas[| n];
					
					
					
				}until(ds_list_find_index(attempts, otherArea) == -1);
				ds_list_add(attempts, otherArea);
				
				if(ds_list_size(attempts) >= ds_list_size(area.neighbors)) break;
				
			}until(ds_list_find_index(visited, otherArea) == -1);
			
			//Treat areas linked by a merged area as if they were already connected
			var connViaMergedArea = (ds_list_find_index(area.mergedAreas, otherArea.num) != -1);
			for(var i = 0; i < ds_list_size(area.mergedAreas); i++){
				if(ds_list_find_index(otherArea.mergedAreas, area.mergedAreas[| i]) != -1){
					connViaMergedArea = true;
					break;
				}
			}
			
							
			var doorPlaced = true;
			//Connect unconnected rooms
			if(ds_list_find_index(area.connectedAreas, otherArea.num) == -1 && !connViaMergedArea){
				var _x, _y;
				var _x2 = -1, _y2 = -1;
				
				//Top
				if(area.point1.y > otherArea.point2.y){
					var x1 = (area.point1.x > otherArea.point1.x)? area.point1.x : otherArea.point1.x;
					var x2 = (area.point2.x < otherArea.point2.x)? area.point2.x : otherArea.point2.x;
					_x = irandom_range(x1, x2);
					_y = area.point1.y-1;
					
					
					var offset = choose(-1, 1);
					if((map[# _x + offset, area.point1.y] == area.num) && (map[# _x + offset, otherArea.point1.y] == otherArea.num)){
						_x2 = _x + offset;
					}else if((map[# _x - offset, area.point1.y] == area.num) && (map[# _x - offset, otherArea.point1.y] == otherArea.num)){
						_x2 = _x - offset;
					}else{
						doorPlaced = false;
					}
				
				//Bottom
				}else if(area.point2.y < otherArea.point1.y){
					var x1 = (area.point1.x > otherArea.point1.x)? area.point1.x : otherArea.point1.x;
					var x2 = (area.point2.x < otherArea.point2.x)? area.point2.x : otherArea.point2.x;
					_x = irandom_range(x1, x2);
					_y = otherArea.point1.y-1;
					
					var offset = choose(-1, 1);
					if((map[# _x + offset, area.point1.y] == area.num) && (map[# _x + offset, otherArea.point1.y] == otherArea.num)){
						_x2 = _x + offset;
					}else if((map[# _x - offset, area.point1.y] == area.num) && (map[# _x - offset, otherArea.point1.y] == otherArea.num)){
						_x2 = _x - offset;
					}else{
						doorPlaced = false;
					}
					
				//Right
				}else if(area.point1.x > otherArea.point2.x){
					var y1 = (area.point1.y > otherArea.point1.y)? area.point1.y : otherArea.point1.y;
					var y2 = (area.point2.y < otherArea.point2.y)? area.point2.y : otherArea.point2.y;
					_y = irandom_range(y1, y2);
					_x = area.point1.x-1;
					
					var offset = choose(-1, 1);
					if((map[# area.point1.x, _y + offset] == area.num) && (map[# otherArea.point1.x, _y + offset] == otherArea.num)){
						_y2 = _y + offset;
					}else if((map[# area.point1.x, _y - offset] == area.num) && (map[# otherArea.point1.x, _y - offset] == otherArea.num)){
						_y2 = _y - offset;
					}else{
						doorPlaced = false;
					}
				
				//Left
				}else{
					var y1 = (area.point1.y > otherArea.point1.y)? area.point1.y : otherArea.point1.y;
					var y2 = (area.point2.y < otherArea.point2.y)? area.point2.y : otherArea.point2.y;
					_y = irandom_range(y1, y2);
					_x = otherArea.point1.x-1;
					
					var offset = choose(-1, 1);
					if((map[# area.point1.x, _y + offset] == area.num) && (map[# otherArea.point1.x, _y + offset] == otherArea.num)){
						_y2 = _y + offset;
					}else if((map[# area.point1.x, _y - offset] == area.num) && (map[# otherArea.point1.x, _y - offset] == otherArea.num)){
						_y2 = _y - offset;
					}else{
						doorPlaced = false;
					}
					
				}
				
				
				if(_y == 19 || _y2 == 19) show_debug_message("Error");
				if(doorPlaced){
					map[# _x, _y] = mapDoorTile;
					if(_x2 != -1) map[# _x2, _y] = mapDoorTile;
					else map[# _x, _y2] = mapDoorTile;
					area.addConnectedArea(otherArea.num);
					otherArea.addConnectedArea(area.num);
					
				}
			}
			
			if(doorPlaced){
				if(ds_list_find_index(visited, area) == -1){
					ds_list_add(visited, area);
				}
				area = otherArea;
			}else{
				ds_list_delete(area.neighbors, ds_list_find_index(area.neighbors, otherArea.num));
			}
		}until(ds_list_size(visited) >= ds_list_size(areas));
		
		//Ensure all merged areas are in connected list even if not connected through above code
		for(var i = 0; i < ds_list_size(areas); i++){
			var area = areas[| i];
			for(var j = 0; j < ds_list_size(area.mergedAreas); j++){
				var merged = area.mergedAreas[| j];
				if(ds_list_find_index(area.connectedAreas, merged) == -1){
					ds_list_add(area.connectedAreas, merged);
				}
			}
		}
}