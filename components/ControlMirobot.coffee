noflo = require 'noflo'
Mirobot = require '../vendor/mirobot.js'

sleep = (ms) ->
  start = new Date().getTime()
  continue while new Date().getTime() - start < ms

class ControlMirobot extends noflo.Component
  description: 'Control Mirobot.'
  icon: 'pencil'

  constructor: ->
    @url = null
    @mirobot = null
    @commands = []
    @points = []

    @inPorts =
      url: new noflo.Port 'string'
      start: new noflo.Port 'bang'
      stop: new noflo.Port 'bang'
      commands: new noflo.ArrayPort 'object'
      points: new noflo.Port 'object'

    @outPorts =
      path: new noflo.Port 'object'

    @inPorts.url.on 'data', (data) =>
      @commands = []
      @url = data
      if not @mirobot?
        console.log 'Connecting on', @url
        @mirobot = new Mirobot @url

    @inPorts.start.on 'data', (data) =>
      if @mirobot?
        @parseThing @commands, 0

    @inPorts.stop.on 'data', (data) =>
      @commands = []
      if @mirobot?
        @mirobot.stop()

    @inPorts.commands.on 'data', (cmd, i) =>
      @commands[i] = cmd

    @inPorts.points.on 'data', (data) =>
      @points = data.items

  parseThing: (thing, currentPoint) ->
    if thing? and thing.cmd? and @[thing.cmd]?
      @[thing.cmd](thing, currentPoint)
    else if thing instanceof Array
      for item, i in thing
        continue unless item?
        @parseThing item, i

  drawCommand: (position) =>
    return unless @inPorts.points.isAttached()
    return unless @outPorts.path.isAttached()
    if position < @points.length-1
      path = []
      path.push @points[position]
      path.push @points[position+1]
      @outPorts.path.send path

  forward: (distance, currentPoint) =>
    @setIcon 'arrow-up'
    @mirobot.move('forward', distance.arg, (state, msg, recursion) =>
      if state != 'started'
        sleep 50
      else
        @drawCommand currentPoint
    )

  back: (distance, currentPoint) =>
    @setIcon 'arrow-down'
    @mirobot.move('back', distance.arg, (state, msg, recursion) =>
      if state != 'started'
        sleep 50
      else
        @drawCommand currentPoint
    )

  left: (angle, currentPoint) =>
    @setIcon 'mail-reply'
    @mirobot.turn('left', angle.arg, (state, msg, recursion) =>
      if state != 'started'
        sleep 50
      else
        @drawCommand currentPoint
    )

  right: (angle, currentPoint) =>
    @setIcon 'mail-forward'
    @mirobot.turn('right', angle.arg, (state, msg, recursion) =>
      if state != 'started'
        sleep 50
      else
        @drawCommand currentPoint
    )

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
