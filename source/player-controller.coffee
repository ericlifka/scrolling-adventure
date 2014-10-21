class PlayerController
    # hitBoxHeight: 90
    # hitBoxWidth: 40
    hitBoxHeight: 34
    hitBoxWidth: 20

    # These represent the bottom-center if the play in world coords
    xPosition: 0
    yPosition: 0

    xVelocity: 0
    yVelocity: 0

    jumpAcceleration: 500
    yAccelerationStep: 1000
    xAccelerationStep: 2000
    xJumpingAccelerationStep: 700
    xAccelerationCap: 400

    facingRight: true
    jumping: false
    jumpReleased: true
    doubleJump: false
    running: false

    spriteScale: 1

    hitBox: null
    sprite: null
    level: null

    constructor: ->

    jumpToPosition: (position) ->
        @xPosition = position.x
        @yPosition = position.y
        # @yPosition = position.y - @hitBoxHeight
        # @xOffset = position.x
        # @yOffset = position.y - @hitBoxHeight

    setupSprites: ->
        frames = [
            PIXI.Sprite.fromFrame('reddude.000').texture
            PIXI.Sprite.fromFrame('reddude.001').texture
            PIXI.Sprite.fromFrame('reddude.002').texture
            PIXI.Sprite.fromFrame('reddude.003').texture
            PIXI.Sprite.fromFrame('reddude.004').texture
            PIXI.Sprite.fromFrame('reddude.005').texture
        ]
        @runningSprite = new PIXI.MovieClip frames

    addToStage: (stage) ->
        # @sprite = PIXI.Sprite.fromImage 'assets/wizard_girl_boots.png'
        # @sprite.position.x = @xOffset
        # @sprite.position.y = @yOffset
        # @sprite.scale.x = @spriteScale
        # @sprite.scale.y = @spriteScale
        # @sprite.pivot.set 16, 0

        @sprite = @runningSprite

        @sprite.scale.x = -@spriteScale
        @sprite.scale.y = @spriteScale
        @sprite.position.x = @xOffset
        @sprite.position.y = @yOffset
        @sprite.pivot.set 40, 0

        stage.addChild @sprite

        # @hitBox = new PIXI.Graphics()
        # @hitBox.beginFill 0xFF0000
        # @hitBox.drawRect @xOffset, @yOffset, @hitBoxWidth, @hitBoxHeight
        # window.box = @hitBox
        # stage.addChild @hitBox

    setLevel: (level) ->
        @level = level

    update: (elapsedTime, inputState) ->
        timeRatio = elapsedTime / 1000

        @updateXVelocity inputState, timeRatio
        @updateYVelocity inputState, timeRatio
        @updatePosition timeRatio
        @updateSprite()

    updateXVelocity: (inputState, timeRatio) ->
        if inputState.right
            @facingRight = true
            @accelerateRight timeRatio

        else if inputState.left
            @facingRight = false
            @accelerateLeft timeRatio

        else if not @jumping
            @slow timeRatio

    updateYVelocity: (inputState, timeRatio) ->
        if inputState.jump and not @jumping and @jumpReleased
            @jumping = true
            @jumpReleased = false
            @yVelocity = @jumpAcceleration

        else if inputState.jump and @jumping and @jumpReleased and not @doubleJump
            @doubleJump = true
            @jumpReleased = false
            @yVelocity = @jumpAcceleration

        else if not inputState.jump
            @jumpReleased = true

        @accelerateDown timeRatio
        @checkFloorCollision timeRatio

    setRunning: ->
        if !@running
            @sprite.gotoAndPlay 0
            @sprite.animationSpeed = 1
            @running = true

    setStopped: ->
        if @running
            @sprite.gotoAndStop 2
            @running = false

    accelerateRight: (timeRatio) ->
        if @jumping
            @xVelocity += @xJumpingAccelerationStep * timeRatio
        else
            @xVelocity += @xAccelerationStep * timeRatio
        @capVelocity()
        @setRunning()

    accelerateLeft: (timeRatio) ->
        if @jumping
            @xVelocity -= @xJumpingAccelerationStep * timeRatio
        else
            @xVelocity -= @xAccelerationStep * timeRatio
        @capVelocity()
        @setRunning()

    accelerateDown: (timeRatio) ->
        @yVelocity -= @yAccelerationStep * timeRatio

    slow: (timeRatio) ->
        if @xVelocity < 0
            @xVelocity += @xAccelerationStep * timeRatio
            if @xVelocity > 0
                @xVelocity = 0

        else if @xVelocity > 0
            @xVelocity -= @xAccelerationStep * timeRatio
            if @xVelocity < 0
                @xVelocity = 0

        if @xVelocity == 0
            @setStopped()

    capVelocity: ->
        if @xVelocity < -@xAccelerationCap
            @xVelocity = -@xAccelerationCap

        if @xVelocity > @xAccelerationCap
            @xVelocity = @xAccelerationCap

    updatePosition: (timeRatio) ->
        @xPosition += @xVelocity * timeRatio
        @yPosition += @yVelocity * timeRatio

    updateSprite: ->
        # Might need to mess with offsets again
        # @sprite.position.x = @xPosition #- @xOffset
        # @sprite.position.y = @yPosition #- @yOffset

        # Need to convert the coords to even integers to
        # prevent anti-aliasing quirks
        @sprite.position.x = Math.round @xPosition - (@hitBoxWidth / 2)
        @sprite.position.y = Math.round @level.height - (@yPosition + 70) # why 70?
        if @facingRight
            @sprite.scale.x = @spriteScale
        else
            @sprite.scale.x = -@spriteScale

    checkFloorCollision: (timeRatio) ->
        xStep = @xPosition + @xVelocity * timeRatio
        yStep = @yPosition + @yVelocity * timeRatio

        collision = @level.testCollision @xPosition, xStep, @yPosition, yStep

        if collision != null
            @jumping = false
            @doubleJump = false
            @yVelocity = 0
            @yPosition = collision
