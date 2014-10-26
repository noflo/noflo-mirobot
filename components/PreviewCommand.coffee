noflo = require 'noflo'

TAU = 2 * Math.PI;
_accuracy = 1000000000;

class PreviewCommand extends noflo.Component
  description: 'Previews a command.'
  icon: 'pencil'

  constructor: ->
    @canvas = null
    @turtle =
      position:
        x: 100
        y: 100
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
      @ctx.beginPath()
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
    console.log 'turn'
    @turtle.vector.x = Math.round(Math.cos(TAU * @turtle.angle))
    @turtle.vector.y = Math.round(Math.sin(TAU * @turtle.angle))
    # @ctx.rotate(@turtle.angle);

  forward: (distance) =>
    console.log 'forward'
    distance = distance.arg

    a = @turtle.angle* (Math.PI/180.0);

    x = Math.round(distance * Math.cos(a))
    y = Math.round(distance * Math.sin(a))

    # x = distance * @turtle.vector.x
    # y = distance * @turtle.vector.y

    console.log "x", x , "y", y, "distance", distance

    @turtle.position.x += x
    @turtle.position.y += y

    # TODO: Check if pendown and change color and draw a path using @ctx
    @ctx.strokeStyle = '#00ff00'
    
    @ctx.linewidth = 1
    console.log 'Line between', @turtle.position.x, @turtle.position.y
    @ctx.stroke()

    # if @turtle.pen?
    #   @ctx.lineTo(@turtle.position.x, @turtle.position.y);
    # else
    #   @ctx.moveTo(@turtle.position.x, @turtle.position.y);
    @ctx.lineTo @turtle.position.x, @turtle.position.y 

  back: (distance) ->
    distance = distance.arg
    @turtle.angle += 180

  left: (angle) =>
    console.log 'left', angle
    if angle.arg?
      @turtle.angle += angle.arg
    else
      @turtle.angle += angle
    @turtle.angle = @turtle.angle % 360
    @turn()

  right: (angle) =>
    console.log 'right', angle
    if angle.arg?
      @turtle.angle -= angle.arg
    else
      @turtle.angle -= angle
    @turtle.angle = @turtle.angle % 360
    @turn()

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
