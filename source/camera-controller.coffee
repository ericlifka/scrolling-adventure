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
        ### Map world coordinates into screen coordinates based on camera position and screen height ###
        [x - @position.x, @height - (y - @position.y)]

    updatePlayerSprite: ->
        # rounding prevents anti-aliasing issues
        [x, y] = @translateCoordinates @player.position.x, @player.position.y + @player.characterHeight
        @player.sprite.position.x = Math.round x
        @player.sprite.position.y = Math.round y
