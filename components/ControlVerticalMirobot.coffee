noflo = require 'noflo'

class ControlVerticalMirobot extends noflo.Component
  icon = 'cog'
  description = 'Send commands to Vertical Mirobot through WebSockets.'
  constructor: ->
    @socket = null
    @commandsCounter = 0
    @toRobot = []
    @commands = []

    @inPorts =
      url: new noflo.Port 'string'
      send: new noflo.Port 'bang'
      commands: new noflo.ArrayPort 'object'
      rawcommand: new noflo.Port 'string'
      gohome: new noflo.Port 'bang'
      sethome: new noflo.Port 'bang'
      penup: new noflo.Port 'bang'
      pendown: new noflo.Port 'bang'

    @inPorts.url.on 'data', (data) =>
      #return unless @socket is null
      socket = new WebSocket data
      console.log 'socket created', socket
      socket.onopen = =>
        @socket = socket
        console.log 'socket opened', socket
        @setup()
        console.log 'bot setup done'
      socket.addEventListener 'message', (m) =>
        console.log 'received from arduino', m, ' sending next command'
        @sendNext()

    @inPorts.send.on 'data', () =>
      @parse @commands
      # send the first command to robot
      @sendNext()
      #@send()

    @inPorts.commands.on 'data', (commands, i) =>
      @commands[i] = commands

    @inPorts.rawcommand.on 'data', (commands) =>
      @send commands

    @inPorts.gohome.on 'data', () =>
      feed_rate = 2000
      @send 'G00 F' + feed_rate + ' X0 Y0;'
      @send 'M114;'

    @inPorts.sethome.on 'data', () =>
      return unless @socket?
      @send 'TELEPORT X0 Y0 Z0;'

    @inPorts.penup.on 'data', () =>
      return unless @socket?
      @send 'G00 Z90;'

    @inPorts.pendown.on 'data', () =>
      return unless @socket?
      @send 'G00 Z0;'

  parse: (commands) =>
    console.log 'parse', commands
    @parseThing commands

  # Recursively parse things and arrays of things
  parseThing: (thing, before, after) =>
    if thing? and thing.type? and @[thing.type]?
      if before?
        before()
      @[thing.type](thing)
      if after?
        after()
    else if thing instanceof Array
      for item in thing
        continue unless item?
        @parseThing item, before, after

  stroke: (stroke) =>
    # Cache current style
    # if stroke.strokestyle?
    #   oldStyle = @context.strokeStyle
    #   @context.strokeStyle = stroke.strokestyle
    # if stroke.linewidth?
    #   oldWidth = @context.linewidth
    #   @context.lineWidth = stroke.linewidth
    # Stroke each thing
    before = ->
      #@context.beginPath()
    after = ->
      #if stroke.closepath
      #  @context.closePath()
      #@context.stroke()
    @parseThing stroke.items, before.bind(@), after.bind(@)
    # Restore style
    # if oldStyle?
    #   @context.strokeStyle = oldStyle
    # if oldWidth?
    #   @context.lineWidth = oldWidth

  pathItem: (thing, i) =>
    # Handle arrays of points
    if thing instanceof Array
      for child, j in thing
        @pathItem child, j
      return
    if thing.type?
      switch thing.type
        when 'point'
          if i is 0
            @point thing
            #@context.moveTo thing.x, thing.y
          else
            @point thing
            #@context.lineTo thing.x, thing.y
        when 'beziercurve'
          @bezierCurve thing
        when 'arc'
          @arc thing

  path: (path) =>
    # Build the path
    for thing, i in path.items
      continue unless thing?
      @pathItem thing, i

  point: (thing) =>
    @toRobot.push [thing.x, thing.y]

  forward: (distance) =>
    return 'FD ' + distance

  right: (angle) =>
    return 'RT ' + angle

  send: (command) =>
    return unless @socket?
    @socket.send command
    console.log 'socket sent', command

  sendNext: () =>
    return unless @commandsCounter < @toRobot.length
    c = @toRobot[@commandsCounter]
    x = c[0] / 5.0
    y = c[1] / 5.0
    console.log 'send next', x, y
    @send 'G01 X' + x + ' Y' + y + ';'
    @commandsCounter += 1

  setup: () =>
    @send 'CONFIG T30.0 B-30.0 L-25.0 R25.0 I1 J-1;'
    @send 'D01 L1.02 R1.02;'
    # @socket.send 'TELEPORT X0 Y0 Z0;'
    # @send 'CONFIG T30.0 B-30.0 L-25.0 R25.0 I1 J-1;\nD01 L1.02 R1.02;\nTELEPORT X0 Y0 Z0;'

  # penup: 90, pendown: 65

exports.getComponent = -> new ControlVerticalMirobot



