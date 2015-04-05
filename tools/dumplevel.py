"""
Convert an image into a level description

A very cheap way to define levels until we get tooling

Player-Start = white
Platforms = blue
Background = green
"""

import os
import sys
import json
import argparse

from PIL import Image

PLAYER = (255, 255, 255, 255)

ENTITIES = {
    str((0, 0, 0, 255)): 0
}

TILES = {
    str((0, 0, 255, 255)):   0,
    str((0, 0, 127, 255)):   1,
    str((255, 0, 0, 255)):   2,
    str((0, 255, 255, 255)): 3,
    str((255, 0, 255, 255)): 4,
}

TILE_MAP = {
    0: {'sprite': 'Platform-Metal', 'type': 'block', 'entity': False},
    1: {'sprite': 'Railings', 'type': 'front', 'entity': False},
    2: {'sprite': 'Platform-Bridge', 'type': 'platform', 'entity': False},
    3: {'sprite': 'RailingsRear', 'type': 'back', 'entity': False},
    4: {'sprite': 'Antenna', 'type': 'back', 'entity': True,
        'entityType': 'Antenna'},
}

SPRITE_DEFS = [
    {
        'id': 'Platform-Metal',
        'type': 'static',
        'frames': ['Platform-Metal']
    },
    {
        'id': 'Platform-Bridge',
        'type': 'static',
        'frames': ['Platform-Bridge']
    },
    {
        'id': 'Railings',
        'type': 'static',
        'frames': ['Railings']
    },
    {
        'id': 'RailingsRear',
        'type': 'static',
        'frames': ['RailingsRear']
    },
    {
        'id': 'Antenna',
        'type': 'animated',
        'frames': [
            'Antenna.000',
            'Antenna.001',
            'Antenna.002',
            'Antenna.003',
        ]
    },
]


class BaseTile(object):

    def __init__(self, generator, coords, dimensions, sprite):
        self.generator = generator
        self.coords = coords
        self.dimensions = dimensions
        self.sprite = sprite

    def tile_descriptor(self):
        x, y = self.coords
        w, h = self.dimensions
        sprite_def = self.generator.sprite_defs[self.sprite]

        return {
            'start': x,
            'end': x + w,
            'height': y,
            'spriteType': sprite_def['type'],
            'frames': sprite_def['frames']
        }

class Block(BaseTile):

    def __init__(self, generator, coords, dimensions, tiledef):
        super(Block, self).__init__(
                generator, coords, dimensions, tiledef['sprite'])

class Platform(BaseTile):

    def __init__(self, generator, coords, dimensions, tiledef):
        super(Platform, self).__init__(
                generator, coords, dimensions, tiledef['sprite'])


class Tile(BaseTile):

    def __init__(self, generator, coords, dimensions, tiledef):
        super(Tile, self).__init__(
                generator, coords, dimensions, tiledef['sprite'])


class Entity(object):

    def __init__(self, entity_type, entity_id, tile_descriptor):
        self.entity_type = entity_type
        self.entity_id = entity_id
        self.tile_descriptor = tile_descriptor

    def serialize(self):
        x, y = self.tile_descriptor.coords
        w, h = self.tile_descriptor.dimensions
        return {
            'id': self.entity_id,
            'type': self.entity_type,
            'x': x,
            'y': y,
            'w': w,
            'h': h,
            'data': {}
        }


class LevelImage(object):

    def __init__(self, image_path):
        self.image_path = image_path
        self.image_name = os.path.basename(image_path)
        self.image = Image.open(self.image_path)
        self.image_width, self.image_height = self.image.size

    def world_coords(self, pos, tile_dimensions):
        x, y = pos
        w, h = tile_dimensions
        return ((x * w), ((self.image_height - 1 - y) * h))


class LevelGenerator(object):

    def __init__(self, name, images):
        self.name = name
        self.images = images
        self.level_images = []
        self.sprite_defs = {}
        for sprite_def in SPRITE_DEFS:
            id = sprite_def['id']
            self.sprite_defs[id] = sprite_def
        for image_path in self.images:
            self.level_images.append(LevelImage(image_path))
        self.background = (0, 255, 0, 255)
        self.tile_dimensions = (64, 64)

        self.blocks = []
        self.platforms = []
        self.front_tiles = []
        self.back_tiles = []

        self.player_start = None

        self.level_width = 0
        self.level_height = 0

        self.entity_id = 0
        self.entities = []

    def get_entity_id(self):
        self.entity_id += 1
        return self.entity_id

    def collect_tile(self, coords, tile_id):
        tile_desc = TILE_MAP[tile_id]
        if tile_desc['type'] == 'block':
            block = Block(self, coords, self.tile_dimensions, tile_desc)
            self.blocks.append(block)
        if tile_desc['type'] == 'platform':
            platform = Platform(self, coords, self.tile_dimensions, tile_desc)
            self.platforms.append(platform)
        elif tile_desc['type'] == 'front':
            tile = Tile(self, coords, self.tile_dimensions, tile_desc)
            self.front_tiles.append(tile)
        elif tile_desc['type'] == 'back':
            tile = Tile(self, coords, self.tile_dimensions, tile_desc)
            self.back_tiles.append(tile)

        if tile_desc.get('entity'):
            entity_type = tile_desc['entityType']
            new_entity = Entity(entity_type, self.get_entity_id(), tile)
            self.entities.append(new_entity)

    def read_level_image(self, level_image):
        if level_image.image_width > self.level_width:
            self.level_width = level_image.image_width
        if level_image.image_height > self.level_height:
            self.level_height = level_image.image_height
        for x in xrange(level_image.image_width):
            for y in xrange(level_image.image_height):
                coords = (x, y)
                pixel = level_image.image.getpixel(coords)
                if str(pixel) in TILES:
                    tile_id = TILES[str(pixel)]
                    world_coords = level_image.world_coords(
                            coords, self.tile_dimensions)
                    self.collect_tile(world_coords, tile_id)
                elif pixel == PLAYER:
                    self.player_start = level_image.world_coords(
                            coords, self.tile_dimensions)
                elif str(pixel) in ENTITIES:
                    pass

    def write_dimensions(self, level):
        w, h = self.tile_dimensions
        width = self.level_width * w
        height = self.level_height * h
        level['dimensions'] = {
            'width': width,
            'height': height
        }

    def write_blocks(self, level):
        level['blocks'] = []
        for block in self.blocks:
            level['blocks'].append(block.tile_descriptor())

    def write_platforms(self, level):
        level['platforms'] = []
        for platform in self.platforms:
            level['platforms'].append(platform.tile_descriptor())

    def write_back_tiles(self, level):
        level['frontTiles'] = []
        for tile in self.front_tiles:
            level['frontTiles'].append(tile.tile_descriptor())

    def write_front_tiles(self, level):
        level['backTiles'] = []
        for tile in self.back_tiles:
            level['backTiles'].append(tile.tile_descriptor())

    def write_player_start(self, level):
        if not self.player_start:
            raise Exception('No player start defined on map')
        x, y = self.player_start
        level['startingPosition'] = {
            'x': x,
            'y': y
        }

    def write_entities(self, level):
        level['entities'] = []
        for entity in self.entities:
            level['entities'].append(entity.serialize())

    def write_level(self):
        level= {}
        level['name'] = self.name
        self.write_dimensions(level)
        self.write_blocks(level)
        self.write_platforms(level)
        self.write_front_tiles(level)
        self.write_back_tiles(level)
        self.write_player_start(level)
        self.write_entities(level)
        print(json.dumps(level, indent=4))

    def gen(self):
        for level_image in self.level_images:
            self.read_level_image(level_image)
        self.write_level()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Create level from image')
    parser.add_argument('--level-name', dest='level_name', required=True,
                        help='ID/Name of the level')
    parser.add_argument('images', help='Path to the image', nargs='+')
    args = parser.parse_args()
    level = LevelGenerator(args.level_name, args.images)
    level.gen()
