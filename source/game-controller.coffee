window.GameController = class GameController
    assetPaths: [
        'assets/wizard_girl_boots.png'
        'assets/RedDudeBounce2x.json',
    ]

    constructor: (@viewport) ->
        @input = new InputController()

        @renderer = new PIXI.WebGLRenderer 1024, 576
        @viewport.appendChild @renderer.view

        @player = new PlayerController()
        @level = new LevelController(@player)

    start: ->
        browserFrameHook = =>
            @nextAnimationFrame()
            requestAnimationFrame browserFrameHook

        loader = new PIXI.AssetLoader @assetPaths
        loader.onComplete = =>
            @setupAssets()
            @level.load "test-level"
            @lastTimestamp = Date.now()
            requestAnimationFrame browserFrameHook

        loader.load()

    nextAnimationFrame: ->
        elapsed = @elapsedSinceLastFrame()
        inputState = @input.getFrameState()

        @level.update elapsed, inputState
        @renderer.render @level.getStage()

    elapsedSinceLastFrame: ->
        now = Date.now()
        elapsed = now - @lastTimestamp
        @lastTimestamp = now
        elapsed

    setupAssets: ->
        @player.setupSprites()
