noflo = require 'noflo'

class Left extends noflo.Component
  description: 'Send a left direction command.'
  icon: 'rotate-left'

  constructor: ->
    @command =
      cmd: 'left'
      arg: null

    @inPorts =
      angle: new noflo.Port 'number'
    @outPorts =
      command: new noflo.Port 'string'

    @inPorts.angle.on 'data', (data) =>
      return unless @outPorts.command.isAttached()
      @command.arg = data
      @outPorts.command.send @command

exports.getComponent = -> new Left