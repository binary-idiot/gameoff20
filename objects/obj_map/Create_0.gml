randomize();
//random_set_seed(723463507);
show_debug_message("Seed: "+ string(random_get_seed()));

scale = 32;
wallTileIndex = 1;
floorTileIndex = 2;

data = generateMap();
map = data.map;
areas = data.areas;
mapWidth = (ds_grid_width(map) * scale);
mapHeight = (ds_grid_height(map) * scale)

room_width = mapWidth;
room_height = mapHeight;

var mapTileLayer = layer_get_id("MapTiles");
var instanceLayer = layer_get_id("Instances");

draw_set_font(fnt_test);
draw_set_color(c_red);

for(var _x = 0; _x < ds_grid_width(map); _x++){
	
	for(var _y = 0; _y < ds_grid_height(map); _y++){
		
		
		if(map[# _x, _y] == mapWallTile){
			tilemap_set_at_pixel(mapTileLayer, wallTileIndex, _x * scale, _y * scale);	
		}else{
			tilemap_set_at_pixel(mapTileLayer, floorTileIndex, _x * scale, _y * scale);	
		}
		
		if(map[# _x, _y] == mapDoorTile && instance_position(_x * scale, _y * scale, obj_door) == noone){
			var door = instance_create_layer(_x * scale, _y * scale, instanceLayer, obj_door)
			
			if(map[# _x, _y + 1] == mapDoorTile){
				door.image_angle = 270;
				door.x += scale;
			}
			
		}
	}
}