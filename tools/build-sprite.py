import os
import json
import argparse

from PIL import Image

class SpriteMaker(object):

    def __init__(self, args):
        self.name = args.sprite_name
        self.image_path = args.image_path
        self.image_name = os.path.basename(self.image_path)
        self.image = Image.open(self.image_path)
        self.image_width, self.image_height = self.image.size
        self.num_frames = args.frames
        self.columns = args.columns
        self.rows = args.rows
        self.frame_width = args.frame_width or self._default_frame_width()
        self.frame_height = args.frame_width or self._default_frame_height()
        self.sprite_width = args.sprite_width or self.frame_width
        self.sprite_height = args.sprite_height or self.frame_height
        self.sprite_offset_x = args.sprite_offset_x
        self.sprite_offset_y = args.sprite_offset_y

    def _default_frame_width(self):
        return self.image_width / self.columns

    def _default_frame_height(self):
        return self.image_height / self.rows

    def gen(self):
        output = {}
        self.gen_meta(output)
        self.gen_frames(output)
        print(json.dumps(output, sort_keys=True, indent=4))

    def gen_meta(self, output):
        output['meta'] = {
            'image': self.image_name,
            'scale': 1,
            'size': {
                'w': self.image_width,
                'h': self.image_height,
            }
        }

    def gen_frames(self, output):
        frames = {}
        for frameno in xrange(self.num_frames):
            rowno = frameno / self.columns
            colno = frameno % self.columns
            frame_name = '{}.{}'.format(self.name, '%03d' % frameno)
            frame = {
                'frame': {
                    'x': colno * self.frame_width,
                    'y': rowno * self.frame_height,
                    'w': self.frame_width,
                    'h': self.frame_height,
                },
                'spriteSourceSize': {
                    'x': self.sprite_offset_x,
                    'y': self.sprite_offset_y,
                    'w': self.sprite_width,
                    'h': self.sprite_height
                },
                'sourceSize': {
                    'w': self.sprite_width,
                    'h': self.sprite_height
                },
                'rotated': False,
                'trimmed': True
            }
            frames[frame_name] = frame
        output['frames'] = frames

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Create Spritesheet Description')
    parser.add_argument('--name', dest='sprite_name', required=True,
                        help='ID/Name of the sprite-sheet')
    parser.add_argument('-r', '--rows', dest='rows', type=int, required=True,
                        help='Number of rows')
    parser.add_argument('-c', '--columns', dest='columns', type=int, required=True,
                        help='Number of columns')
    parser.add_argument('-n', '--frames', dest='frames', type=int, required=True,
                        help='Number of frames')
    parser.add_argument('--sprite-offset-x', dest='sprite_offset_x', default=0,
                        type=int, help='x-offset of sprite in frame')
    parser.add_argument('--sprite-offset-y', dest='sprite_offset_y', default=0,
                        type=int, help='y-offset of sprite in frame')
    parser.add_argument('--sprite-width', dest='sprite_width', type=int,
                        default=None, help='Sprite width')
    parser.add_argument('--sprite-height', dest='sprite_height', type=int,
                        default=None, help='Sprite height')
    parser.add_argument('--frame-width', dest='frame_width', type=int,
                        default=None, help='Sprite width')
    parser.add_argument('--frame-height', dest='frame_height', type=int,
                        default=None, help='Sprite height')
    parser.add_argument('image_path', help='Path to the image')
    args = parser.parse_args()
    sprite_maker = SpriteMaker(args)
    sprite_maker.gen()
