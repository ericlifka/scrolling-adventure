level_descriptions = level_descriptions or { }

class LevelController
    camera: null
    player: null
    loader: null
    entities: null

    blocks: null
    platforms: null
    frontTiles: null
    backTiles: null
    bullets: null

    constructor: ->
        @blocks = []
        @platforms = []
        @frontTiles = []
        @backTiles = []
        @entities = []
        @bullets = {
            friendly: []
            enemy: []
        }

    load: (levelIdentifier) ->
        @description = @loader.getLevelDescription levelIdentifier
        @loadTiles()
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

    testPlatformCollision: (x, y, xStep, yStep, hitBox) ->
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
        return collY

    testPointInRect: (x, y, x1, y1, x2, y2) ->
        return x >= x1 and x <= x2 and y >= y1 and y <= y2

    testStepIntersects: (v, vStep, x) ->
        return (v <= x and vStep >= x) or (v >= x and vStep <= x)

    testBlockCollision: (x, y, xStep, yStep, hitBox) ->
        collX = null
        collY = null
        {width, height} = hitBox
        y2 = y + height
        y2Step = yStep + height
        x2 = x + width
        x2Step = xStep + width
        for {start, end, height} in @description.blocks
            top = height + 64
            # Test the intersection of each edge of the 
            # box.  Since we are doing time-influenced
            # steps we need to find which edge is the 
            # collisions side

            # right-bottom (x2, y)
            if @testPointInRect(x2Step, yStep, start, height, end, top)
                if @testStepIntersects y, yStep, top
                    collY = top
                else if @testStepIntersects x2, x2Step, start
                    collX = start - hitBox.width
            # right-top (x2, y2)
            else if @testPointInRect(x2Step, y2Step, start, height, end, top)
                if @testStepIntersects y2, y2Step, height
                    collY = height - hitBox.height
                else if @testStepIntersects x2, x2Step, start
                    collX = start - hitBox.width
            # left-bottom (x, y)
            else if @testPointInRect(xStep, yStep, start, height, end, top)
                if @testStepIntersects y, yStep, top
                    collY = top
                else if @testStepIntersects x, xStep, end
                    collX = end
            # left-top (x, y2)
            else if @testPointInRect(xStep, y2Step, start, height, end, top)
                if @testStepIntersects y2, y2Step, height
                    collY = height - hitBox.height
                else if @testStepIntersects x, xStep, end
                    collX = end

            if collX and collY
                break
        return [collX, collY]

    testCollision: (x, y, xStep, yStep, hitBox) ->
        # This is all very cheat-y but it seems to work
        #
        # x, y -> The bottom left coordinate of the box
        # xStep, yStep -> The new bottom left coordinate being tested
        # hitBox -> width and height of the entity tested
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

        [collX, collY] = @testBlockCollision(x, y, xStep, yStep, hitBox)

        if not collY
            collY = @testPlatformCollision(x, y, xStep, yStep, hitBox)

        if (not collX) and (xStep < 0.0)
            # simple left side test... may go away
            collX = 0.0

        if (collX != null) or (collY != null)
            return [collX, collY, false]

        if yStep < 0.0
            return [null, null, true]

        [null, null, false]

    loadTile: (tile) ->
        if tile.spriteType == 'static'
            sprite = PIXI.Sprite.fromFrame tile.frames[0]
        else if tile.spriteType == 'animated'
            sprites = []
            for frame in tile.frames
                sprites.push (PIXI.Sprite.fromFrame frame).texture
            sprite = new PIXI.MovieClip sprites
            sprite.gotoAndPlay 0
            sprite.animationSpeed = 0.25
        return {
            height: tile.height
            start: tile.start
            length: length
            sprite: sprite
        }

    loadTiles: ->
        for block in @description.blocks
            @blocks.push(@loadTile block)
        for platform in @description.platforms
            @platforms.push(@loadTile platform)
        for tile in @description.frontTiles
            @frontTiles.push(@loadTile tile)
        for tile in @description.backTiles
            @backTiles.push(@loadTile tile)

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
