level_descriptions = level_descriptions or { }

class LevelController
    camera: null
    player: null

    constructor: ->
        @platforms = []

    load: (levelIdentifier) ->
        @description = level_descriptions[levelIdentifier]
        @loadPlatforms()
        @loadBackground()
        # Loads assets for the level
        @camera.initialize @description.dimensions
        # Resets the view/player
        @reset()

    reset: ->
        @player.jumpToPosition @description.startingPosition
        @camera.reset()

    loadBackground: ->
        @background = PIXI.Sprite.fromImage 'assets/Background.png'
        @background.position.x = 0
        @background.position.y = 0

    update: (elapsedTime, inputState) ->
        @player.update elapsedTime, inputState

    testCollision: (x, xStep, y, yStep) ->
        # Return the floor height if there was a collision
        # and null if there was not
        # FIXME: returning flag if player death was detected
        #        need to think about how player state can
        #        be affected by the level
        for {start, end, height} in @description.platforms
            # This is all very cheat-y but it seems to work
            if xStep < end and xStep >= start and y >= height and yStep < height
                return [height, false]

        if y >= 0.0 and yStep < 0.0
            return [0, false]

        if yStep < 10.0
            return [null, true]

        [null, false]

    loadPlatforms: ->
        for platform in @description.platforms
            length = platform.end - platform.start
            sprite = new PIXI.Sprite.fromImage 'assets/Platform-Metal.png'
            sprite.width = length
            @platforms.push {
                height: platform.height
                start: platform.start
                length: length
                sprite: sprite
            }

        null
