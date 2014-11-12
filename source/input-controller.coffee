###
    Button codes from default controller mapping:
    Arrows:
        up:     12
        down:   13
        left:   14
        right:  15

    Actions:
        A:  0
        B:  1
        X:  2
        Y:  3

    Meta:
        Select: 8
        Start:  9

    Shoulder:
        left bumper:    4
        right bumper:   5
        left trigger:   6
        left trigger:   7

    Axes: (found under the axes array unlike buttons)
        left stick x:   0
        left stick y:   1
        right stick x:  2
        right stick y:  3
###

class InputController
    keyCache: null

    constructor: ->
        @keyCache = { }

        # TODO: String.fromCharCode can only handle alphanumeric,
        # this needs to be replaced with a more robust solution at some point
        document.addEventListener 'keydown', (event) =>
            @keyCache[ String.fromCharCode(event.keyCode) ] = true

        document.addEventListener 'keyup', (event) =>
            @keyCache[ String.fromCharCode(event.keyCode) ] = false

    clearCache: ->
        @keyCache = { }

    getFrameState: ->
        @checkForGamePad()

        left: @keyCache['A']
        right: @keyCache['D']
        up: @keyCache['W']
        down: @keyCache['S']
        jump: @keyCache[' ']
        fire: @keyCache['J']
        pause: @keyCache['P']

    checkForGamePad: ->
        gamepad = navigator.getGamepads()[0]
        if gamepad
            for i in [0...gamepad.buttons.length]
                button = gamepad.buttons[i]
                if button.pressed
                    console.log "pressed #{i}, value '#{button.value}'"


#        if not @gamePad
#            @gamePad = navigator.getGamepads()[0]
#            if @gamePad
#                console.log "Found it!"
#        else
#            @getGamePadState()
#
#    getGamePadState: ->
#        if @gamePad.buttons[0].pressed
#            console.log "pressed!"
#
#
#
#        null

