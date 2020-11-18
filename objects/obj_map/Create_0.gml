


randomize();
//random_set_seed(723463507);
show_debug_message("Seed: "+ string(random_get_seed()));

scale = TILESIZE;
marginSize = 5;
margin =  marginSize * scale;

data = generateMap();
map = data.map;
areas = data.areas;
mapWidth = (ds_grid_width(map) * scale) + margin*2;
mapHeight = (ds_grid_height(map) * scale) + margin*2;

room_width = mapWidth;
room_height = mapHeight;

var instanceLayer = layer_get_id("Instances");
var mapTilemap = layer_tilemap_get_id(layer_get_id("MapTiles"));
var collisionTilemap = layer_tilemap_get_id(layer_get_id("CollisionTiles"));

buildMap(instanceLayer, mapTilemap, collisionTilemap);
placeStart(instanceLayer, mapTilemap, collisionTilemap);



