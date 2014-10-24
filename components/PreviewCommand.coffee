noflo = require 'noflo'
Mirobot = require '../vendor/mirobot.js'

sleep = (ms) ->
  start = new Date().getTime()
  continue while new Date().getTime() - start < ms

class PreviewCommand extends noflo.Component
  description: 'Previews a command.'
  icon: 'pencil'

  constructor: ->
    # Default Mirobot's websocket URI
    @url = 'ws://10.10.100.254:8899/websocket'
    @mirobot = null

    @inPorts =
      url: new noflo.Port 'string'
      disconnect: new noflo.Port 'bang'
      command: new noflo.Port 'object'

    @outPorts =
      completed: new noflo.Port 'string'
      connected: new noflo.Port 'string'
      disconnected: new noflo.Port 'string'

    @inPorts.url.on 'data', (data) =>
      @url = data
      if not @mirobot?
        @mirobot = new Mirobot @url, () =>
          return unless @outPorts.connected.isAttached()
          @outPorts.connected.send 'connected'

    @inPorts.disconnect.on 'data', (data) =>
      if @mirobot?
        @mirobot.stop (state, msg, recursion) =>
          @outPorts.disconnected.send 'disconnected'

    @inPorts.command.on 'data', (data) =>
      if @mirobot?
        @parseThing data

  shutdown: =>
    if @mirobot?
      @mirobot.stop()

  parseThing: (thing) ->
    if thing? and thing.cmd? and @[thing.cmd]?
      @[thing.cmd](thing)
    else if thing instanceof Array
      for item in thing
        continue unless item?
        @parseThing item

  # drawCommand: (position) =>
  #   return unless @inPorts.points.isAttached()
  #   return unless @outPorts.path.isAttached()
  #   if position < @points.length-1
  #     path = []
  #     path.push @points[position]
  #     path.push @points[position+1]
  #     @outPorts.path.send path

  forward: (distance, currentPoint) =>
    @setIcon 'arrow-up'
    @mirobot.move 'forward', distance.arg, (state, msg, recursion) =>
      if state is 'complete'
        @outPorts.complete.send state
      # if state != 'started'
      #   sleep 50
      # else
      #   @drawCommand currentPoint

  back: (distance, currentPoint) =>
    @setIcon 'arrow-down'
    @mirobot.move 'back', distance.arg, (state, msg, recursion) =>
      if state is 'complete'
        @outPorts.complete.send state
      # if state != 'started'
      #   sleep 50
      # else
      #   @drawCommand currentPoint

  left: (angle, currentPoint) =>
    @setIcon 'mail-reply'
    @mirobot.turn 'left', angle.arg, (state, msg, recursion) =>
      if state is 'complete'
        @outPorts.complete.send state
      # if state != 'started'
      #   sleep 50
      # else
      #   @drawCommand currentPoint

  right: (angle, currentPoint) =>
    @setIcon 'mail-forward'
    @mirobot.turn 'right', angle.arg, (state, msg, recursion) =>
      if state is 'complete'
        @outPorts.complete.send state
      # if state != 'started'
      #   sleep 50
      # else
      #   @drawCommand currentPoint

  pause: ->
    @mirobot.pause (state, msg, recursion) =>
      if state is 'complete'
        @outPorts.complete.send state

  resume: ->
    @mirobot.resume (state, msg, recursion) =>
      if state is 'complete'
        @outPorts.complete.send state

  ping: ->
    @mirobot.ping (state, msg, recursion) =>
      if state is 'complete'
        @outPorts.complete.send state

  penup: ->
    @mirobot.penup (state, msg, recursion) =>
      if state is 'complete'
        @outPorts.complete.send state

  pendown: ->
    @mirobot.pendown (state, msg, recursion) =>
      if state is 'complete'
        @outPorts.complete.send state

exports.getComponent = -> new PreviewCommand
