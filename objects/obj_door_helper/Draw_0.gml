with(obj_door){
	if(isOpen && image_angle != 0){
		draw_sprite_ext(spr_door, 2, x, y,
		image_xscale, image_yscale, image_angle, image_blend, image_alpha);
	}
}