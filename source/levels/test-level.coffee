level_descriptions = level_descriptions or { }

# Level platforms expressed in world coordinates
level_descriptions['test-level'] =
    dimensions:
        width: 2000
        height: 576

    platforms: [
        {
            start: 0
            end: 2000
            height: 100
        }
    ]

    startingPosition:
        x: 20
        y: 400
