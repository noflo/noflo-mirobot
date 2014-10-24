noflo = require 'noflo'

class Repeat extends noflo.Component
  description: 'Repeat commands.'
  icon: 'cog'

  constructor: ->
    @commands = []
    @times = null

    @inPorts =
      times: new noflo.Port 'number'
      commands: new noflo.ArrayPort 'string'
    @outPorts =
      command: new noflo.Port 'array'

    @inPorts.times.on 'data', (data) =>
      @times = data
      @repeat()

    @inPorts.commands.on 'data', (data, i) =>
      @commands[i] = data
      @repeat()

  repeat: ->
    return unless @outPorts.command.isAttached()
    return unless @commands.length?
    return unless @times?

    out = (@commands for i in [0...@times])
    @outPorts.command.send out

exports.getComponent = -> new Repeat