level_descriptions = level_descriptions or { }

class LevelController
    player: null
    stage: null

    # NOTE: stage.width may return NaN
    #       we need to store the dimensions
    #       of the level ourselves
    constructor: (@player, @width, @height) ->
        @stage = new PIXI.Stage 0xf5f5f5

    load: (levelIdentifier) ->
        @description = level_descriptions[levelIdentifier]
        @setInitialPlayerPosition()

        @addPlatformsToStage()
        @player.addToStage @stage
        @player.setLevel this

    update: (elapsedTime, inputState) ->
        @player.update elapsedTime, inputState

    getStage: ->
        @stage

    setInitialPlayerPosition: ->
        @player.jumpToPosition @description.startingPosition

    translateCoordinates: (x, y) ->
        [x, @height - y]

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

    addPlatformsToStage: ->
        for {start, end, height} in @description.platforms
            [x, y] = @translateCoordinates start, height
            platform = new PIXI.Graphics()
            platform.beginFill 0x000000
            platform.drawRect x, y, end - start, 5
            @stage.addChild platform
