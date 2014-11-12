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
        if gamepad and gamepad.buttons[0].pressed
            console.log 'pressed!'


#        if not @gamePad
#            @gamePad = navigator.getGamepads()[0]
#            if @gamePad
#                console.log "Found it!"
#        else
#            @getGamePadState()

    getGamePadState: ->
        if @gamePad.buttons[0].pressed
            console.log "pressed!"

#        for i in [0...@gamePad.buttons.length]
#            button = @gamePad.buttons[i]
#            if button.pressed
#                console.log "pressed #{i}, value '#{button.value}'"
#
#        null

