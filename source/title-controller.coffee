window.TitleController = class TitleController

    constructor: (@width, @height) ->
        @stage = new PIXI.Stage 0xf5f5f5
        @background = PIXI.Sprite.fromImage 'assets/Title.png'
        @background.position.x = 0
        @background.position.y = 0
        @stage.addChild @background

