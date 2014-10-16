class PlayerController
    hitBoxHeight: 90
    hitBoxWidth: 40

    # These represent the upper left corner of the hit box
    xPosition: 0
    yPosition: 0

    # The offset of the box's origin point from the stage's origin point
    xOffset: 0
    yOffset: 0

    xVelocity: 0
    yVelocity: 0

    jumpAcceleration: 500
    yAccelerationStep: 1000
    xAccelerationStep: 2000
    xJumpingAccelerationStep: 700
    xAccelerationCap: 400

    facingRight: true
    jumping: false

    hitBox: null
    sprite: null

    constructor: ->

    jumpToPosition: (position) ->
        @xPosition = position.x
        @yPosition = position.y - @hitBoxHeight
        @xOffset = position.x
        @yOffset = position.y - @hitBoxHeight

    addToStage: (stage) ->
        @sprite = PIXI.Sprite.fromImage 'assets/wizard_girl_boots.png'
        @sprite.position.x = @xOffset
        @sprite.position.y = @yOffset
        @sprite.scale.x = 3
        @sprite.scale.y = 3
        @sprite.pivot.set 16, 0

        stage.addChild @sprite

#        @hitBox = new PIXI.Graphics()
#        @hitBox.beginFill 0xFF0000
#        @hitBox.drawRect @xOffset, @yOffset, @hitBoxWidth, @hitBoxHeight
#        window.box = @hitBox
#        stage.addChild @hitBox

    update: (elapsedTime, inputState) ->
        timeRatio = elapsedTime / 1000

        if inputState.right
            @facingRight = true
            @accelerateRight timeRatio

        else if inputState.left
            @facingRight = false
            @accelerateLeft timeRatio

        else if not @jumping
            @slow timeRatio

        if inputState.jump and not @jumping
            @jumping = true
            @yVelocity += @jumpAcceleration

        if @jumping
            @accelerateDown timeRatio
            @checkFloorCollision timeRatio

        @updatePosition timeRatio
        @updateSprite()

    accelerateRight: (timeRatio) ->
        if @jumping
            @xVelocity += @xJumpingAccelerationStep * timeRatio
        else
            @xVelocity += @xAccelerationStep * timeRatio
        @capVelocity()

    accelerateLeft: (timeRatio) ->
        if @jumping
            @xVelocity -= @xJumpingAccelerationStep * timeRatio
        else
            @xVelocity -= @xAccelerationStep * timeRatio
        @capVelocity()

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

    capVelocity: ->
        if @xVelocity < -@xAccelerationCap
            @xVelocity = -@xAccelerationCap

        if @xVelocity > @xAccelerationCap
            @xVelocity = @xAccelerationCap

    updatePosition: (timeRatio) ->
        @xPosition += @xVelocity * timeRatio
        @yPosition -= @yVelocity * timeRatio

    updateSprite: ->
        @sprite.position.x = @xPosition #- @xOffset
        @sprite.position.y = @yPosition #- @yOffset
        if @facingRight
            @sprite.scale.x = -3
        else
            @sprite.scale.x = 3

    checkFloorCollision: (timeRatio) ->
        y = @yPosition
        yStep = y - @yVelocity * timeRatio
        platformHeight = 500 - @hitBoxHeight

        if y < platformHeight and yStep >= platformHeight
            @jumping = false
            @yVelocity = 0
            @yPosition = platformHeight
