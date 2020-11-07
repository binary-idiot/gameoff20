scale = 20;
data = generateMap();
map = data.map;
areas = data.areas;
width = (2*scale) + (ds_grid_width(map) * scale);
height = (2*scale) + (ds_grid_height(map) * scale)

room_width = width;
room_height = height;
surface_resize(application_surface, width, height);
display_set_gui_size(width, height);

draw_set_font(fnt_test);
draw_set_color(c_white);