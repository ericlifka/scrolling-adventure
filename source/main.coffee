main = ->
    game = new GameController document.body
    game.initialize ->
        game.start()

window.onload = main
