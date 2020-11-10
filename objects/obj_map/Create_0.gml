scale = 32;
wallTileIndex = 1;
floorTileIndex = 2;

data = generateMap();
map = data.map;
areas = data.areas;
mapWidth = (ds_grid_width(map) * scale);
mapHeight = (ds_grid_height(map) * scale)

room_width = mapWidth;
room_height = mapHeight;

global.mapStructureLayer = layer_create(-1);
global.mapStructureTilemap = layer_tilemap_create(global.mapStructureLayer, 0, 0, ts_structure, room_width, room_height);