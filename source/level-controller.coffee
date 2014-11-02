level_descriptions = level_descriptions or { }

class LevelController
    camera: null
    player: null
    loader: null
    entities: []

    platforms: null
    bullets: null

    constructor: ->
        @platforms = []
        @bullets = {
            friendly: []
            enemy: []
        }

    load: (levelIdentifier) ->
        @description = @loader.getLevelDescription levelIdentifier
        @loadPlatforms()
        @loadBackground()
        # Loads assets for the level
        @camera.initialize @description.dimensions
        # Resets the view/player
        @reset()

    reset: ->
        @player.jumpToPosition @description.startingPosition
        @camera.reset()
        @clearBullets()

    loadBackground: ->
        @background = PIXI.Sprite.fromImage 'assets/Background.png'
        @background.position.x = 0
        @background.position.y = 0

    update: (elapsedTime, inputState) ->
        timeRatio = elapsedTime / 1000

        @player.update timeRatio, inputState
        for entity in @entities
            entity.update timeRatio
        @updateBullets timeRatio

    testCollision: (x, y, xStep, yStep, hitBox) ->
        # This is all very cheat-y but it seems to work
        #
        # x, y -> The bottom left coordinate of the box
        # xStep, yStep -> The new bottom left coordinate being tested
        # hitBox 
        # 
        # Returns the tuple [collision-x, collision-y, died]
        # where collision-x/y are the bottom left coordinates
        # FIXME: returning flag if player death was detected
        #        need to think about how player state can
        #        be affected by the level
        collX = null
        collY = null
        {width, height} = hitBox
        x2 = x + width
        x2Step = xStep + width
        for {start, end, height} in @description.platforms
            top = height + 64
            # if either bottom point is in the x-range
            # then we need to test the new Y.
            if (xStep < end and xStep >= start) \
                    or (x2Step < end and x2Step >= start)
                if y >= top and yStep < top
                    collY = top
                    yStep = top # new yStep based on collision
                    break

        for {start, end, height} in @description.platforms
            top = height + 64
            if yStep >= height and yStep < top
                # Bottom edge is in the height of the tile
                if (x2Step > start and x2Step <= end)
                    # right edge intersects tile
                    collX = start - width
                    break
                else if (xStep > start and xStep <= end)
                    # left edge intersects tile
                    collX = end
                    break

        if collX or collY
            return [collX, collY, false]

        if y >= 0.0 and yStep < 0.0
            return [null, 0, false]

        if yStep < 10.0
            return [null, null, true]

        [null, null, false]

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

    spawnFriendlyBullet: (position, velocity) ->
        bullet = {
            position
            velocity
            sprite: new PIXI.Sprite.fromImage 'assets/bullet.png'
        }
        @bullets.friendly.push bullet
        @camera.addBullet bullet

    updateBullets: (timeRatio) ->
        for bullet in @bullets.friendly
            bullet.position.x += bullet.velocity.x * timeRatio
            bullet.position.y += bullet.velocity.y * timeRatio

    clearBullets: ->
        @camera.clearBullets @bullets.friendly
        @camera.clearBullets @bullets.enemy
        @bullets.friendly = []
        @bullets.enemy = []
