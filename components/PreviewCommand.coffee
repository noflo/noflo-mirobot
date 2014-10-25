noflo = require 'noflo'
Mirobot = require '../vendor/mirobot.js'

TAU = 2 * Math.PI;

class PreviewCommand extends noflo.Component
  description: 'Previews a command.'
  icon: 'pencil'

  constructor: ->
    @canvas = null
    @turtle =
      position:
        x: 0
        y: 0
      vector:
        x: 0
        y: 1
      angle: 90
      pen: true

    @inPorts =
      command: new noflo.Port 'object'
      canvas: new noflo.Port 'object'

    @outPorts =
      canvas: new noflo.Port 'object'

    @inPorts.command.on 'data', (data) =>
      return unless @canvas?
      # For each command, update turtle state and draw on canvas
      @ctx = @canvas.getContext '2d'
      @parseThing data

    @inPorts.canvas.on 'data', (data) =>
      @canvas = data

  shutdown: ->
    # ???

  parseThing: (thing) ->
    if thing? and thing.cmd? and @[thing.cmd]?
      @[thing.cmd](thing)
    else if thing instanceof Array
      for item in thing
        continue unless item?
        @parseThing item

  turn: () =>
    @turtle.vector.x = Math.round(Math.sin(TAU * @turtle.angle))
    @turtle.vector.y = Math.round(Math.cos(TAU * @turtle.angle))

  forward: (distance) =>
    distance = distance.arg
    x = distance * @turtle.vector.x
    y = distance * @turtle.vector.y

    @turtle.position.x += x
    @turtle.position.y += y

    # TODO: Check if pendown and change color and draw a path using @ctx
    if @turtle.pen?
      @ctx.strokeStyle = '#00ff00'
    else
      @ctx.strokeStyle = '#000'
    @ctx.linewidth = '2'
    @ctx.beginPath()
    console.log 'Line between', @turtle.position.x, @turtle.position.y
    @ctx.lineTo @turtle.position.x, @turtle.position.y

  back: (distance) ->
    distance = distance.arg
    # TODO

  left: (angle) =>
    @turtle.angle += angle
    @turn()

  right: (angle) =>
    @left -angle

  pause: ->
    # Do nothing

  resume: ->
    # Do nothing

  ping: ->
    # Blink?

  penup: ->
    @turtle.pen = false

  pendown: ->
    @turtle.pen = true

exports.getComponent = -> new PreviewCommand
