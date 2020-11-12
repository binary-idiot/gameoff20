target = obj_player;

global.cameraX = 0;
global.cameraY = 0;

global.cameraWidth = 16 * global.baseTileSize;
global.cameraHeight = 9 * global.baseTileSize;

view_enabled = true;

view_set_visible(viewId, true);
view_set_wport(viewId, 1280);
view_set_hport(viewId, 720);

camera = camera_create_view(0, 0, global.cameraWidth, global.cameraHeight, 0, -1, -1, -1, 0, 0);
view_set_camera(viewId, camera);

displayWidth = 1920;
displayHeight = 1080;

window_set_size(displayWidth, displayHeight);
surface_resize(application_surface, displayWidth, displayHeight);

display_set_gui_size(global.cameraWidth, global.cameraHeight);

setCameraPos(target);

alarm[0] = 1;