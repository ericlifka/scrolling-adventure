class CameraController
    level: null
    position: null # in world coordinates

    constructor: (@width, @height) ->
        @stage = new PIXI.Stage 0xf5f5f5
        @position = { x: 0, y: 0 }

    initialize: ->
        @initializePlayer()
        @initializePlatforms()

    update: ->
        @updatePlayerSprite()

    initializePlayer: ->
        @player.initialize()
        @stage.addChild @player.sprite

    initializePlatforms: ->
        for platform in @level.platforms
            [platform.sprite.position.x, platform.sprite.position.y] = @translateCoordinates platform.start, platform.height
            @stage.addChild platform.sprite

    translateCoordinates: (x, y) ->
        [x, @height - y]

    updatePlayerSprite: ->
        # Need to convert the coords to even integers to
        # prevent anti-aliasing quirks
        @player.sprite.position.x = Math.round @player.position.x
        @player.sprite.position.y = Math.round @height - (@player.position.y + 70) # why 70?
