function generateMap(){
	randomize();
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
	mergeAreaSize = round((minAreaSize*maxAreaSize)/2);
	
	var map = createBSPGrid(width, length, minAreaSize, maxAreaSize);
	
	mergeAreas(map);
	
	//Check if area is merged by finding corners of area then checking one over each side to see if area is surrounded by walls, 
	//if cell is not a wall that cell belongs to a merged area
	
	return map;
}


function createBSPGrid(width, length, minAreaSize, maxAreaSize){	
	//Setup data structures
	var grid = ds_grid_create(width, length);
	
	//Set everything to walls
	ds_grid_set_region(grid, 0, 0, width-1, length-1, wall);
	
	//Assign cords for area
	var x1 = 1, y1 = 1;
	var x2 = width - 2, y2 = length - 2;
	
	//Assign area
	ds_grid_set_region(grid, x1, y1, x2, y2, areaNum);
	
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
		
			ds_grid_set_region(grid, x1, y1, x2, hSplit - 1, areaNum);
			leaf(grid, x1, y1, x2, hSplit - 1, minAreaSize, maxAreaSize);
			areaNum++;
		
			ds_grid_set_region(grid, x1, hSplit + 1, x2, y2, areaNum);
			leaf(grid, x1, hSplit + 1, x2, y2, minAreaSize, maxAreaSize);
		
			ds_grid_set_region(grid, x1, hSplit, x2, hSplit, wall);
		}else{
			leafFailed = true;
		}
		
	}else{
		
		if(!(x1 + size >= x2 - size)){
			var vSplit = irandom_range(x1 + oSize , x2 - oSize);
		
			ds_grid_set_region(grid, x1, y1, vSplit - 1, y2, areaNum);
			leaf(grid, x1, y1, vSplit - 1, y2, minAreaSize, maxAreaSize);
			areaNum++;
		
			ds_grid_set_region(grid, vSplit + 1, y1, x2, y2, areaNum);
			leaf(grid, vSplit + 1, y1, x2, y2, minAreaSize, maxAreaSize);
		
			ds_grid_set_region(grid, vSplit, y1, vSplit, y2, wall);
		}else{
			leafFailed = true;	
		}
	}
	
	if(leafFailed && is_undefined(dir)) leaf(grid, x1, y1, x2, y2, minAreaSize, maxAreaSize, !horiz);
}
	
function mergeAreas(map){
	var merges = irandom_range(0, ceil(areaNum/4));
	var completedMerges = 0;
	var usedAreas = ds_list_create();
	
	var mapWidth = ds_grid_width(map), mapLength = ds_grid_height(map);
	
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
				
				//Choose point on side
				//Check in both directions until perpendicular wall is reached on either side
				//Change sepparating wall to be nom of the area being computed
				
			}
	}
}