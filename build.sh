#!/bin/sh

rsync -r static/ out
cp -r assets/ out/assets
cp -r lib/ out/lib
cp -r levels/ out/levels
cp package.json out

cd out
zip -r scrolling-adventure.nw *
cd ../
