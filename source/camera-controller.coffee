class CameraController
    level: null
    position: null # in world coordinates
    levelDimensions: null
    thresholds: null

    constructor: (@width, @height) ->
        @stage = new PIXI.Stage 0xf5f5f5
        @position = { x: 0, y: 0 }
        @thresholds =
            left: Math.round @width * .25
            right: Math.round @width * .75

    initialize: (@levelDimensions) ->
        @initializePlatforms()
        @initializePlayer()

    update: ->
        @checkPlayerPosition()
        @updatePlayerSprite()
        @updatePlatforms()
        @updateBullets()

    reset: ->
        @position.x = 0
        @position.y = 0
        @update()

    initializePlayer: ->
        @player.initialize()
        @stage.addChild @player.sprite

    addBullet: (bullet) ->
        @stage.addChild bullet.sprite

    initializePlatforms: ->
        @stage.addChild @level.background
        for platform in @level.platforms
            @stage.addChild platform.sprite

    translateCoordinates: (x, y) ->
        ### Map world coordinates into screen coordinates based on camera position and screen height ###
        [x - @position.x, @height - (y - @position.y)]

    checkPlayerPosition: ->
        if @player.position.x - @position.x < @thresholds.left && @position.x > 0
            @position.x = @player.position.x - @thresholds.left

        if @player.position.x - @position.x > @thresholds.right && @position.x + @width < @levelDimensions.width
            @position.x = @player.position.x - @thresholds.right

    updatePlayerSprite: ->
        # rounding prevents anti-aliasing issues
        [x, y] = @translateCoordinates @player.position.x, @player.position.y + @player.characterHeight
        @player.sprite.position.x = Math.round x
        @player.sprite.position.y = Math.round y

    updatePlatforms: ->
        for platform in @level.platforms
            [platform.sprite.position.x, platform.sprite.position.y] = @translateCoordinates platform.start, platform.height

    updateBullets: ->
        for bullet in @level.bullets.friendly
            [bullet.sprite.position.x, bullet.sprite.position.y] = @translateCoordinates bullet.position.x, bullet.position.y
