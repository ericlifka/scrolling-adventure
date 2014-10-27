checkError = (error, cb) ->
    if error
        console.error error
        cb?(error)
        throw error

class LevelLoader
    constructor: ->
        @descriptions = { }
        @fs = require 'fs'

    getLevelDescription: (level) ->
        if @descriptions.hasOwnProperty level
            @descriptions[level]
        else
            throw "Cannot find description for level: #{level}"

    importAll: (callback) ->
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
                    callback()

    readJson: (data) ->
        description = JSON.parse data
        if description?.name
            @descriptions[description.name] = description
