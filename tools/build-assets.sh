#!/bin/sh
python build-sprite.py -r 1 -c 8 -n 8 --name=reddude ../assets/JepPackDude.png > ../assets/JetPackDude.json
python dumplevel.py --level-name=level1 ../assets/level-01-platforms.png ../assets/level-01-entities.png ../assets/level-01-tiles.png > ../levels/level1.json
