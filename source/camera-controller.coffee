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
        @initializeBackTiles()
        @initializePlatforms()
        @initializePlayer()
        @initializeFrontTiles()

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

    initializeFrontTiles: ->
        for tile in @level.frontTiles
            @stage.addChild tile.sprite

    initializeBackTiles: ->
        @stage.addChild @level.background
        for tile in @level.backTiles
            @stage.addChild tile.sprite

    initializePlatforms: ->
        for platform in @level.platforms
            @stage.addChild platform.sprite

    translateCoordinates: (coords) ->
        # Map world coordinates into screen coordinates based on
        # camera position and screen height 
        [x, y] = coords
        [x - @position.x, @height - (y - @position.y)]

    checkPlayerPosition: ->
        if @player.position.x - @position.x < @thresholds.left && @position.x > 0
            @position.x = @player.position.x - @thresholds.left

        if @player.position.x - @position.x > @thresholds.right && @position.x + @width < @levelDimensions.width
            @position.x = @player.position.x - @thresholds.right

    updatePlayerSprite: ->
        # rounding prevents anti-aliasing issues
        [x, y] = @translateCoordinates @player.spriteCoordinates()
        @player.sprite.position.x = Math.round x
        @player.sprite.position.y = Math.round y

    updateTile: (tile) ->
        spriteCoordinates = [tile.start, tile.height + 64]
        [x, y] = @translateCoordinates spriteCoordinates
        tile.sprite.x = Math.round x
        tile.sprite.y = Math.round y

    updatePlatforms: ->
        for platform in @level.platforms
            @updateTile platform
        for tile in @level.frontTiles
            @updateTile tile
        for tile in @level.backTiles
            @updateTile tile

    updateBullets: ->
        for bullet in @level.bullets.friendly
            bulletSpriteCoordinates = [bullet.position.x, bullet.position.y + 4]
            [x, y] = @translateCoordinates bulletSpriteCoordinates
            bullet.sprite.position.x = Math.round x
            bullet.sprite.position.y = Math.round y

    clearBullets: (bullets) ->
        for bullet in bullets
            @stage.removeChild bullet.sprite
