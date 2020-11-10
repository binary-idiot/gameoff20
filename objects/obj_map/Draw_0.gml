for(var _x = 0; _x < ds_grid_width(map); _x++){
	for(_y = 0; _y < ds_grid_height(map); _y++){
		if(map[# _x, _y] == mapWallTile){
			tilemap_set_at_pixel(global.mapStructureTilemap, wallTileIndex, _x * scale, _y * scale);	
		}else{
			tilemap_set_at_pixel(global.mapStructureTilemap, floorTileIndex, _x * scale, _y * scale);	
		}
	}
}