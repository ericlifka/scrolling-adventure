level_descriptions = level_descriptions or { }

class LevelController
    load: (levelIdentifier) ->
        @description = level_descriptions[levelIdentifier]
        @player.jumpToPosition @description.startingPosition
        @loadPlatforms()

    update: (elapsedTime, inputState) ->
        @player.update elapsedTime, inputState

    translateCoordinates: (x, y) ->
        [x, 576 - y]

    testCollision: (x, xStep, y, yStep) ->
        # Return the floor height if there was a collision
        # and null if there was not
        for {start, end, height} in @description.platforms
            # This is all very cheat-y but it seems to work
            if xStep < end and xStep > start and y >= height and yStep < height
                return height
        if y >= 0.0 and yStep < 0.0
            return 0
        null

    loadPlatforms: ->
        for {start, end, height} in @description.platforms
            [x, y] = @translateCoordinates start, height
            platform = new PIXI.Graphics()
            platform.beginFill 0x000000
            platform.drawRect x, y, end - start, 5
            @camera.stage.addChild platform
