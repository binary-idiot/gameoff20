hDir = 0;
vDir = 0;

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

var collisionTilemap = layer_tilemap_get_id("CollisionTIles");

if(hDir == -1 &&  tilemap_get_at_pixel(collisionTilemap, bbox_left-1, bbox_bottom) == global.collisionTileIndex){
	hDir = 0;	
}
if(hDir == 1 && tilemap_get_at_pixel(collisionTilemap, bbox_right+1, bbox_bottom) == global.collisionTileIndex){
	hDir = 0;
}
if(vDir == -1 && tilemap_get_at_pixel(collisionTilemap, x, y-1) == global.collisionTileIndex){
	vDir = 0;	
}
if(vDir == 1 && tilemap_get_at_pixel(collisionTilemap, x, bbox_bottom+1) == global.collisionTileIndex){
	vDir = 0;	
}

x += mvSpeed * hDir;
y += mvSpeed * vDir;

if(hDir != 0){
	image_xscale = hDir;	
}