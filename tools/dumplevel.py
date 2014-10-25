"""
Convert an image into a level description

A very cheap way to define levels until we get tooling

Player-Start = white
Platforms = blue
Background = green
"""

import os
import json

from PIL import Image

HEADER = """level_descriptions = level_descriptions or { }

# Level platforms expressed in world coordinates
level_descriptions['%s'] ="""

PLAYER = (255, 255, 255, 255)

TILES = {
    str((0, 0, 255, 255)): 0
}

class Platform(object):

    def __init__(self, coords, dimensions, tile_id):
        self.coords = coords
        self.dimensions = dimensions
        self.tile_id = tile_id

class LevelGenerator(object):

    def __init__(self, name, image_path):
        self.name = name
        self.image_path = image_path
        self.image_name = os.path.basename(image_path)
        self.image = Image.open(self.image_path)
        self.image_width, self.image_height = self.image.size
        self.background = (0, 255, 0, 255)
        self.tile_dimensions = (64, 64)

        self.platforms = []
        self.player_start = None

    def world_coords(self, pos):
        x, y = pos
        w, h = self.tile_dimensions
        return ((x * w), ((self.image_height - y) * h))

    def collect_platform(self, coords, tile_id):
        self.platforms.append(Platform(coords, self.tile_dimensions, tile_id))

    def read_level_image(self):
        for x in xrange(self.image_width):
            for y in xrange(self.image_height):
                coords = (x, y)
                pixel = self.image.getpixel(coords)
                if str(pixel) in TILES:
                    tile_id = TILES[str(pixel)]
                    world_coords = self.world_coords(coords)
                    self.collect_platform(world_coords, tile_id)
                elif pixel == PLAYER:
                    self.player_start = self.world_coords(coords)

    def write_dimensions(self):
        w, h = self.tile_dimensions
        width = self.image_width * w
        height = self.image_height * h
        lines = [
            '    dimensions:',
            '        width: {}'.format(width),
            '        height: {}'.format(height)
        ]
        output = '\n'.join(lines)
        print output

    def write_platforms(self):
        print '    platforms: ['
        for platform in self.platforms:
            x, y = platform.coords
            w, h = platform.dimensions
            lines = [
                '        {',
                '            start: {}'.format(x),
                '            end: {}'.format(x + w),
                '            height: {}'.format(y),
                '        },'
            ]
            output = '\n'.join(lines)
            print output
        print '    ]'

    def write_player_start(self):
        if not self.player_start:
            raise Exception('No player start defined on map')
        x, y = self.player_start
        print '    startingPosition:'
        print '        x: {}'.format(x)
        print '        y: {}'.format(y)

    def write_level(self):
        print HEADER % self.name
        self.write_dimensions()
        self.write_platforms()
        self.write_player_start()

    def gen(self):
        self.read_level_image()
        self.write_level()

if __name__ == '__main__':
    level = LevelGenerator('level-01', '../assets/level-01.png')
    level.gen()
