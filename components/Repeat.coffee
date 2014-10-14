noflo = require 'noflo'

class Repeat extends noflo.Component
  description: 'Repeat commands.'
  icon: 'cog'

  constructor: ->
    @command = null
    @times = null

    @inPorts =
      times: new noflo.Port 'number'
      command: new noflo.Port 'string'
    @outPorts =
      command: new noflo.Port 'string'

    @inPorts.times.on 'data', (data) =>
      @times = data
      @repeat()

    @inPorts.command.on 'data', (data) =>
      @command = data
      @repeat()

  repeat: ->
    return unless @outPorts.command.isAttached()
    return unless @command?
    return unless @times?

    commands = (@command for i in [0...@times])
    console.log commands
    @outPorts.command.send commands

exports.getComponent = -> new Repeat