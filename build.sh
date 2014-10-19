#!/bin/sh

rsync -r static/ out
cp -r assets/ out/assets
cp -r lib/ out/lib
