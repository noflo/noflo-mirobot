noflo = require 'noflo'
Mirobot = require '../vendor/mirobot.js'

class ControlMirobot extends noflo.Component
  description: 'Control Mirobot.'
  icon: 'paint-brush'

  constructor: ->
    @url = null
    @commands = []
    @mirobot = null

    @inPorts =
      url: new noflo.Port 'string'
      start: new noflo.Port 'bang'
      stop: new noflo.Port 'bang'
      commands: new noflo.ArrayPort 'object'

    @inPorts.url.on 'data', (data) =>
      @url = data
      console.log 'Connecting on', @url
      if not @mirobot?
        @mirobot = new Mirobot @url
  
    @inPorts.start.on 'data', (data) =>
      if @mirobot?
        @parse @commands

    @inPorts.stop.on 'data', (data) =>
      if @mirobot?
        @mirobot.stop()

    @inPorts.commands.on 'data', (cmd, i) =>
      @commands[i] = cmd

  parse: (cmd) ->
    console.log 'parsing', cmd
    @parseThing cmd

  parseThing: (thing) ->
    if thing? and thing.cmd? and @[thing.cmd]?
      @[thing.cmd](thing)
    else if thing instanceof Array
      for item in thing
        continue unless item?
        @parseThing item

  forward: (distance) ->
    @mirobot.move('forward', distance.arg)

  back: (distance) ->
    @mirobot.move('back', distance.arg)

  left: (angle) ->
    @mirobot.turn('left', angle.arg)

  right: (angle) ->
    @mirobot.turn('right', angle.arg)

  pause: ->
    @mirobot.pause()

  resume: ->
    @mirobot.resume()

  ping: ->
    @mirobot.ping()

  penup: ->
    @mirobot.penup()

  pendown: ->
    @mirobot.pendown()

exports.getComponent = -> new ControlMirobot