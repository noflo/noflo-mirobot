noflo = require 'noflo'

class ControlMirobot extends noflo.Component
  icon = 'cog'
  description = 'Send commands to Mirobot through WebSockets.'
  constructor: ->
    @socket = null
    @commands = []

    @inPorts =
      url: new noflo.Port 'string'
      send: new noflo.Port 'bang'
      commands: new noflo.ArrayPort 'object'
      rawcommand: new noflo.Port 'string'

    @inPorts.url.on 'data', (data) =>
      return unless @socket is null
        @socket = new WebSockets payload

    @inPorts.send.on 'data', () =>
      @parse @commands
      @send()

    @inPorts.commands.on 'data', (commands, i) =>
      @commands[i] = commands

    @inPorts.rawcommand.on 'data', (commands) =>
      return unless @socket isnt null
        @setup()
        @send commands

  parse: (commands) =>
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

  forward: (distance) =>
    return 'FD ' + distance

  right: (angle) =>
    return 'RT ' + angle

  send: (command) =>
    @socket.send 'cmd', command

  setup: () =>
    @send('CONFIG T30.0 B-30.0 L-25.0 R25.0 I1 J-1;\nD01 L1.02 R1.02;\nTELEPORT X0 Y0 Z0;')

exports.getComponent = -> new ControlMirobot



