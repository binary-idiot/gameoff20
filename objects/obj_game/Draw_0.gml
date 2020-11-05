for(_x = 0; _x < ds_grid_width(map); _x++){
	for(_y = 0; _y < ds_grid_height(map); _y++){
		if(map[# _x, _y] == -1){
			draw_sprite(spr_test, 0, 10+_x*10, 10+_y*10);
		}
	}
}