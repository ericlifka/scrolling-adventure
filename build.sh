#!/bin/sh

rsync -r static/ build
cp -r assets/ build/assets
cp -r lib/ build/lib
