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
        gamePad = navigator.getGamepads()[0]
        {
            up: @keyCache['W'] or gamePad?['buttons'][12]['pressed']
            down: @keyCache['S'] or gamePad?['buttons'][13]['pressed']
            left: @keyCache['A'] or gamePad?['buttons'][14]['pressed']
            right: @keyCache['D'] or gamePad?['buttons'][15]['pressed']

            jump: @keyCache[' '] or gamePad?['buttons'][0]['pressed']
            fire: @keyCache['J'] or gamePad?['buttons'][1]['pressed']
            pause: @keyCache['P'] or gamePad?['buttons'][9]['pressed']
        }
