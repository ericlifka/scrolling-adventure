class CameraController
    level: null

    constructor: (@width, @height) ->
        @stage = new PIXI.Stage 0xf5f5f5

    initialize: ->
        @initializePlayer()
        @initializePlatforms()

    initializePlayer: ->
        @player.initialize()
        @stage.addChild @player.sprite

    initializePlatforms: ->
        for platform in @level.platforms
            [platform.sprite.position.x, platform.sprite.position.y] = @translateCoordinates platform.start, platform.height
            @stage.addChild platform.sprite

    translateCoordinates: (x, y) ->
        [x, @height - y]
