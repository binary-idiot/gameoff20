var mvSpeed = global.baseTileSize;
var hDir = 0;
var vDir = 0;

if(keyboard_check_pressed(vk_up)){
	vDir = -1;	
}

if(keyboard_check_pressed(vk_down)){
	vDir = 1;
	
}

if(keyboard_check_pressed(vk_left)){
	hDir = -1;
}

if(keyboard_check_pressed(vk_right)){
	hDir = 1;	
}

mapTilemap = layer_tilemap_get_id("MapTiles");

if(hDir == -1 &&  tilemap_get_at_pixel(mapTilemap, x-sprite_width, bbox_bottom) == global.wallTileIndex){
	hDir = 0;	
}
if(hDir == 1 && tilemap_get_at_pixel(mapTilemap, x+(sprite_width/2), bbox_bottom) == global.wallTileIndex){
	hDir = 0;
}
if(vDir == -1 && tilemap_get_at_pixel(mapTilemap, x, y-1) == global.wallTileIndex){
	vDir = 0;	
}
if(vDir == 1 && tilemap_get_at_pixel(mapTilemap, x, bbox_bottom+1) == global.wallTileIndex){
	vDir = 0;	
}

x += mvSpeed * hDir;
y += mvSpeed * vDir;