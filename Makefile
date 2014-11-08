COFFEE=coffee
TARGET=out/scrolling-adventure.nw
SOURCES=$(wildcard source/*.coffee)
ASSETS=$(wildcard assets/*)
LIBS=$(wildcard lib/*.js)
LEVELS=$(wildcard levels/*.json)
STATIC=$(wildcard static/*)

all:	$(TARGET) 

$(TARGET): out/scrolling.js out/assets out/lib out/levels $(STATIC)
	cp -r static/* out/
	cp package.json out
	cd out && zip -r scrolling-adventure.nw * && cd ../

out/scrolling.js: $(SOURCES)
	mkdir -p out
	cat $(SOURCES) | $(COFFEE) --compile --stdio > $@

out/assets: $(ASSETS)
	mkdir -p out
	cp -r assets out/
	touch $@

out/lib: $(LIBS)
	mkdir -p out
	cp -r lib out/
	touch $@

out/levels: $(LEVELS)
	mkdir -p out
	cp -r levels out/
	touch $@

.PHONY: clean
clean:
	rm -rf out/

run:
	node-webkit out/
