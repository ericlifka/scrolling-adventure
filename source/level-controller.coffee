level_descriptions = level_descriptions or { }

class LevelController
    camera: null
    player: null
    loader: null

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
        @updateBullets timeRatio

    testCollision: (x, xStep, y, yStep) ->
        # Returns the tuple [collision-x, collision-y, died]
        # and null if there was not
        # FIXME: returning flag if player death was detected
        #        need to think about how player state can
        #        be affected by the level
        playerWidth = 5
        collX = null
        collY = null
        for {start, end, height} in @description.platforms
            # This is all very cheat-y but it seems to work
            top = height + 64
            if xStep < end and xStep >= start
                if y >= top and yStep < top
                    collY = top
                    yStep = top
                    break

        for {start, end, height} in @description.platforms
            top = height + 64
            if yStep >= height and yStep < top
                if ((x + playerWidth) <= start \
                        and (xStep + playerWidth) > start)
                    collX = start - playerWidth
                    break
                else if ((x - playerWidth) >= end \
                        and (xStep - playerWidth) < end)
                    collX = end + playerWidth
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
