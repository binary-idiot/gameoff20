

for(_x = 0; _x < ds_grid_width(map); _x++){
	for(_y = 0; _y < ds_grid_height(map); _y++){
		var xPos = 10+_x*10, yPos = 10+_y*10;
		if(map[# _x, _y] == -1){
			draw_sprite(spr_test, 0, xPos, yPos);
		}
		draw_text(xPos, yPos, ds_grid_get(map, _x, _y));
	}
}