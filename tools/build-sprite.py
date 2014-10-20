import os
import json

from PIL import Image

class SpriteMaker(object):

    def __init__(self, name, image_path, num_frames, cols, rows, options=None):
        self.name = name
        self.image_path = image_path
        self.image_name = os.path.basename(image_path)
        self.image = Image.open(self.image_path)
        self.image_width, self.image_height = self.image.size
        self.num_frames = num_frames
        self.columns = cols
        self.rows = rows
        options = options or {}
        self.frame_width = options.get('frame_width',
                                       self._default_frame_width())
        self.frame_height = options.get('frame_height',
                                        self._default_frame_height())
        self.sprite_width = options.get('sprite_width', self.frame_width)
        self.sprite_height = options.get('sprite_height', self.frame_height)
        self.sprite_offset_x = options.get('sprite_offset_x', 0)
        self.sprite_offset_y = options.get('sprite_offset_y', 0)

    def _default_frame_width(self):
        return self.image_width / self.columns

    def _default_frame_height(self):
        return self.image_height / self.rows

    def gen(self, output_path):
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
        colids = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
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
    options = {'sprite_width': 20,
               'sprite_height': 34,
               'sprite_offset_x': 18,
               'sprite_offset_y': 18}
    sprite_maker = SpriteMaker('reddude', '../assets/RedDudeBounce2x.png',
                               6, 6, 1, options=options)
    sprite_maker.gen('output.json')
