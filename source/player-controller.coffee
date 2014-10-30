class PlayerController
    # rectangle to calculate collisions against
    hitBox: null

    # physical vectors
    position: null
    velocity: null

    # character state machine properties
    facingRight: true
    running: false
    jumping: false
    jumpReleased: true
    doubleJump: false

    # constants to adjust physics calculations
    jumpAcceleration: 500           # upward velocity when jumping
    yAccelerationStep: 1000         # gravitational acceleration down
    xAccelerationStep: 2000         # rate of acceleration when on the ground
    xJumpingAccelerationStep: 700   # rate of acceleration when in the air
    xAccelerationCap: 400           # maximum velocity in the horizontal direction

    sprite: null
    spriteScale: 1
    characterHeight: 70 # represents the magical bullshit offset we have to move the character sprite by to get it to show up in the right place

    level: null

    fireRate: 1000  # milliseconds to reload
    lastFire: null
    bulletSpeed: 750
    gunHeight: 20

    constructor: ->
        @hitBox = { height: 34, width: 20 }
        @position = { x: 0, y: 0 }
        @velocity = { x: 0, y: 0 }

    jumpToPosition: (position) ->
        @position.x = position.x
        @position.y = position.y

    reset: ->
        # other things eventually
        @velocity = { x: 0, y: 0 }
        @lastFire = new Date()

    setupSprites: ->
        @sprite = new PIXI.MovieClip [
            PIXI.Sprite.fromFrame('reddude.000').texture
            PIXI.Sprite.fromFrame('reddude.001').texture
            PIXI.Sprite.fromFrame('reddude.002').texture
            PIXI.Sprite.fromFrame('reddude.003').texture
            PIXI.Sprite.fromFrame('reddude.004').texture
            PIXI.Sprite.fromFrame('reddude.005').texture
        ]

    initialize: ->
        @sprite.scale.x = -@spriteScale
        @sprite.scale.y = @spriteScale
        @sprite.position.x = @position.x
        @sprite.position.y = @position.y
        @sprite.pivot.set 40, 0

    update: (timeRatio, inputState) ->
        @updateXVelocity inputState, timeRatio
        @updateYVelocity inputState, timeRatio
        @updatePosition timeRatio
        @updateDirection()
        @checkWeaponFire inputState

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
            @velocity.y = @jumpAcceleration

        else if inputState.jump and @jumping and @jumpReleased and not @doubleJump
            @doubleJump = true
            @jumpReleased = false
            @velocity.y = @jumpAcceleration

        else if not inputState.jump
            @jumpReleased = true

        @accelerateDown timeRatio
        @checkFloorCollision timeRatio

    accelerateRight: (timeRatio) ->
        if @jumping
            @velocity.x += @xJumpingAccelerationStep * timeRatio
        else
            @velocity.x += @xAccelerationStep * timeRatio

        @capVelocity()
        @setRunning()

    accelerateLeft: (timeRatio) ->
        if @jumping
            @velocity.x -= @xJumpingAccelerationStep * timeRatio
        else
            @velocity.x -= @xAccelerationStep * timeRatio

        @capVelocity()
        @setRunning()

    accelerateDown: (timeRatio) ->
        @velocity.y -= @yAccelerationStep * timeRatio

    slow: (timeRatio) ->
        x = @velocity.x
        if x < 0
            x += @xAccelerationStep * timeRatio
            if x > 0 then x = 0

        else if x > 0
            x -= @xAccelerationStep * timeRatio
            if x < 0 then x = 0

        @velocity.x = x

        if x == 0
            @setStopped()

    setRunning: ->
        if not @running
            @sprite.gotoAndPlay 0
            @sprite.animationSpeed = 1
            @running = true

    setStopped: ->
        if @running
            @sprite.gotoAndStop 2
            @running = false

    capVelocity: ->
        if @velocity.x < -@xAccelerationCap
            @velocity.x = -@xAccelerationCap

        if @velocity.x > @xAccelerationCap
            @velocity.x = @xAccelerationCap

    updatePosition: (timeRatio) ->
        @position.x += @velocity.x * timeRatio
        @position.y += @velocity.y * timeRatio

    updateDirection: ->
        if @facingRight
            @sprite.scale.x = @spriteScale
        else
            @sprite.scale.x = -@spriteScale

    checkFloorCollision: (timeRatio) ->
        xStep = @position.x + @velocity.x * timeRatio
        yStep = @position.y + @velocity.y * timeRatio

        [collision, died] = @level.testCollision @position.x, xStep, @position.y, yStep

        if died
            @level.reset()

        if collision
            @jumping = false
            @doubleJump = false
            @velocity.y = 0
            @position.y = collision

    checkWeaponFire: (inputState) ->
        if inputState.fire
            now = new Date()
            if now - @lastFire > @fireRate
                @lastFire = now
                @level.spawnFriendlyBullet @bulletPosition(), @bulletVelocity()

    bulletPosition: ->
        x: @position.x
        y: @position.y + @gunHeight

    bulletVelocity: ->
        x: (if @facingRight then 1 else -1) * @bulletSpeed
        y: 0
