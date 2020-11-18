function buildMap(instanceLayer, mapTilemap, collisionTilemap){
	for(var _x = 0; _x < ds_grid_width(map); _x++){
	
	for(var _y = 0; _y < ds_grid_height(map); _y++){
		
		var xPos = (_x * scale) + margin;
		var yPos = (_y * scale) + margin;
		
		
		if(map[# _x, _y] == mapWallTile){
			var wallTile = TileIndex.DefaultWall;
			if(_x == 0 || _x == ds_grid_width(map)-1){
				
				if(_y == 0){
					if(_x == 0){
						wallTile = TileIndex.TlExterior;	
					}else{
						wallTile = TileIndex.TrExterior;	
					}
				}else if(_y == ds_grid_height(map)-1){
						if(_x == 0){
						wallTile = TileIndex.BlExterior;	
					}else{
						wallTile = TileIndex.BrExterior;	
					}
				}else{
					if(_y % 10 == 0){
						wallTile = TileIndex.VExterior2;	
					}else if(_y % 5 == 0){
						wallTile = TileIndex.VExterior1;	
					}else{
						wallTile = TileIndex.VExterior3;
					}
				}	
			}else if(_y == 0 || _y == ds_grid_height(map)-1){
					if(_x % 10 == 0){
						wallTile = TileIndex.HExterior2;	
					}else if(_x % 5 == 0){
						wallTile = TileIndex.HExterior1;	
					}else{
						wallTile = TileIndex.HExterior3;
					}
			}
			
			
			tilemap_set_at_pixel(mapTilemap, wallTile, xPos, yPos);
			tilemap_set_at_pixel(collisionTilemap, global.collisionTileIndex, xPos, yPos);
		}else{
			tilemap_set_at_pixel(mapTilemap, TileIndex.DefaultFloor, xPos, yPos);	
		}
		
		if(map[# _x, _y] == mapDoorTile && instance_position(xPos, yPos, obj_door) == noone){
			var door = instance_create_layer(xPos, yPos, instanceLayer, obj_door)
			
			if(map[# _x, _y + 1] == mapDoorTile){
				door.image_angle = 270;
				door.x += scale;
			}
			
		}
	}
}	
}
	
function placeStart(instanceLayer, mapTilemap, collisionTilemap){
	var dir = choose(-1, 1);
	var randX = irandom_range(0, ds_grid_width(map)-4);
	var startPoint = randX;
	var validStart;
	
	do{
		validStart = true;
		if(dir == -1){
			for(var offset = 1; offset < 3; offset++){
				if(ds_grid_get(map, startPoint + offset, 2) == mapWallTile) validStart = false;
			}
		}else{
			for(var offset = 1; offset < 3; offset++){
				if(ds_grid_get(map, startPoint + offset, ds_grid_height(map)-2) == mapWallTile) validStart = false;
			}
		}
		
		if(!validStart){
			if(startPoint < ds_grid_width(map)-5){
				startPoint++;
			}else{
				startPoint = 0;	
			}
		}
		
		if(startPoint == randX){
			dir *= -1;	
		}
		
	}until(validStart);
	
	var startY = (dir == -1)? margin : ((ds_grid_height(map)-1) * scale) + margin;
	
	var _y = startY;
	var _x = (startPoint * scale) + margin;
	while(_y >= 0 && _y < room_height){
		tilemap_set_at_pixel(mapTilemap, TileIndex.AirlockWall, _x, _y);
		tilemap_set_at_pixel(collisionTilemap, global.collisionTileIndex, _x, _y);
		
		tilemap_set_at_pixel(mapTilemap, TileIndex.AirlockFloor, _x + scale, _y);
		tilemap_set_at_pixel(mapTilemap, TileIndex.AirlockFloor, _x + (scale*2), _y);
		
		tilemap_set_at_pixel(collisionTilemap, 0, _x + scale, _y);
		tilemap_set_at_pixel(collisionTilemap, 0, _x + (scale*2), _y);
		
		tilemap_set_at_pixel(mapTilemap, TileIndex.AirlockWall, _x + (scale*3), _y);
		tilemap_set_at_pixel(collisionTilemap, global.collisionTileIndex, _x + (scale*3), _y);
		
		_y += dir * scale;
	}
	
	instance_create_layer(_x + scale, startY, instanceLayer, obj_airlock);
	instance_create_layer(_x + scale, startY + (dir * scale * marginSize), instanceLayer, obj_airlock_exit);
	
	instance_create_layer(_x + scale + (TILESIZE/2), startY + (dir * scale * 3), instanceLayer, obj_player);
	
}