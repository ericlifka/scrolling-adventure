# This comment line is very important for reasons beyond logic, compilation will break if its removed.
State =
    GM_TITLE : 0
    GM_MENU : 1
    GM_GAME : 2
    GM_PAUSE : 3

window.GameController = class GameController
    assetPaths: [
        'assets/Title.png'
        'assets/wizard_girl_boots.png'
        'assets/JetPackDude.json'
        'assets/RedDudeTileSet2x.json'
        'assets/platform_tile.png'
        'assets/Background.png'
        'assets/Platform-Metal.png'
        'assets/bullet.png'
        'assets/turret.png'
        'assets/enemy_bullet.png'
    ]

    overlay: null

    constructor: (@viewport) ->
        @loader = new LevelLoader()
        @renderer = new PIXI.WebGLRenderer(1024, 576)
        @camera = new CameraController(1024, 576)
        @input = new InputController()
        @player = new PlayerController()
        @level = new LevelController()
        @title = new TitleController()
        @gameMode = State.GM_TITLE
        @injectServices()

        @viewport.appendChild @renderer.view

    injectServices: ->
        @player.camera = @level.camera = @camera
        @camera.player = @level.player = @player
        @camera.level = @player.level = @level
        @level.loader = @loader

    initialize: (callback) ->
        createjs.Sound.registerSound 'assets/jump.wav', 'jump'
        createjs.Sound.registerSound 'assets/pew.wav', 'pew'
        loader = new PIXI.AssetLoader @assetPaths
        loader.onComplete = =>
            @setupAssets()
            @loadLevelDescriptions callback

        loader.load()

    start: ->
        browserFrameHook = =>
            @nextAnimationFrame()
            requestAnimationFrame browserFrameHook

        @lastTimestamp = Date.now()
        requestAnimationFrame browserFrameHook

    setPauseScreen: (stage) ->
        @overlay = new PIXI.DisplayObjectContainer
        grayout = new PIXI.Graphics()
        grayout.position.x = 0
        grayout.position.y = 0
        grayout.beginFill 0x000000, 0.33
        grayout.drawRect 0, 0, 1024, 576
        grayout.endFill
        @overlay.addChild grayout
        stage.addChild @overlay

    removePauseScreen: (stage) ->
        stage.removeChild @overlay
        @overlay = null

    nextAnimationFrame: ->
        elapsed = @elapsedSinceLastFrame()
        switch @gameMode
            when State.GM_GAME
                inputState = @input.getFrameState()
                @level.update elapsed, inputState
                @camera.update()
                @renderer.render @camera.stage
                if inputState.pause
                    @gameMode = State.GM_PAUSE
                    @setPauseScreen @camera.stage
                    @input.clearCache()

            when State.GM_TITLE
                @renderer.render @title.stage
                inputState = @input.getFrameState()
                if inputState.jump or inputState.pause
                    @gameMode = State.GM_GAME
                    @input.clearCache()

            when State.GM_PAUSE
                inputState = @input.getFrameState()
                @renderer.render @camera.stage
                if inputState.pause
                    @removePauseScreen @camera.stage
                    @gameMode = State.GM_GAME
                    @input.clearCache()

            when State.GM_MENU
                null # nothing

    elapsedSinceLastFrame: ->
        now = Date.now()
        elapsed = now - @lastTimestamp
        @lastTimestamp = now
        elapsed

    setupAssets: ->
        @player.setupSprites()

    loadLevelDescriptions: (callback) ->
        @loader.importAll =>
            @level.load "level1"
            callback()
