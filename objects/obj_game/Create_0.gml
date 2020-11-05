map = scr_alt_generator();
width = 20 + ds_grid_width(map) * 10;
height = 20 + ds_grid_height(map) * 10;

room_width = width;
room_height = height;
surface_resize(application_surface, width, height);
display_set_gui_size(width, height);