checkError = (error, cb) ->
    if error
        console.error error
        cb?(error)
        throw error

class LevelLoader
    constructor: ->
        @descriptions = { }
        @fs = require 'fs'

    loadAll: (callback) ->
        @fs.readdir './levels', (error, files) =>
            checkError error, callback
            @loadFromFileList files, callback

    loadFromFileList: (files, callback) ->
        loaded = 0
        total = files.length
        for file in files
            @fs.readFile "./levels/#{file}", (error, data) =>
                checkError error, callback

                @readJson data

                loaded += 1
                if loaded >= total
                    console.log @descriptions
                    callback()

    readJson: (data) ->
        description = JSON.parse data
        if description?.name
            @descriptions[description.name] = description
