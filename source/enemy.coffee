class Enemy
    position: null
    velocity: null

    hitBox: null
    sprite: null

    level: null

    constructor: (@position, @sprite, @hitBox) ->
        @velocity =
            x: 0
            y: 0

    update: (timeRatio) ->
        @updateVelocity timeRatio
        @checkForCollisions timeRatio
        @updatePosition timeRatio

    updateVelocity: (timeRatio) ->
        # nothing by default, different enemies implement different movement strategies

    checkForCollisions: (timeRatio) ->
        # This feels like something we'll want, but I don't have anything to put here right now

    updatePosition: (timeRatio) ->
        # default movement uses velocity, can be overridden for different effect
        @position.x += @velocity.x * timeRatio
        @position.y += @velocity.y * timeRatio