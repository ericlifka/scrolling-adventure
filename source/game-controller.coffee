window.GameController = class GameController
    assetPaths: [
        'assets/wizard_girl_boots.png'
        'assets/RedDudeBounce2x.json'
        'assets/platform_tile.png'
        'assets/Background.png'
        'assets/Platform-Metal.png'
    ]

    constructor: (@viewport) ->
        @renderer = new PIXI.WebGLRenderer(1024, 576)
        @camera = new CameraController(1024, 576)
        @input = new InputController()
        @player = new PlayerController()
        @level = new LevelController()
        @injectServices()

        @viewport.appendChild @renderer.view

    injectServices: ->
        @player.camera = @level.camera = @camera
        @camera.player = @level.player = @player
        @camera.level = @player.level = @level

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
        @camera.update()
        @renderer.render @camera.stage

    elapsedSinceLastFrame: ->
        now = Date.now()
        elapsed = now - @lastTimestamp
        @lastTimestamp = now
        elapsed

    setupAssets: ->
        @player.setupSprites()
