for(var _x = 0; _x < ds_grid_width(map); _x++){
	draw_text(((_x + 1) * scale), 0, _x);	
}

for(var _y = 0; _y < ds_grid_height(map); _y++){
	draw_text(0, ((_y + 1) * scale), _y);	
}

for(var _x = 0; _x < ds_grid_width(map); _x++){
	for(var _y = 0; _y < ds_grid_height(map); _y++){
		var xPos = scale + (_x * scale), yPos = scale + (_y * 20);
		if(map[# _x, _y] == -1){
			draw_sprite(spr_test, 0, xPos, yPos);
		}
		draw_text(xPos, yPos, ds_grid_get(map, _x, _y));
	}
}