noflo = require 'noflo'

class Forward extends noflo.Component
  description: 'Send a forward direction command.'
  icon: 'forward'

  constructor: ->
    @command =
      cmd: 'forward'
      arg: 100

    @inPorts =
      distance: new noflo.Port 'number'
    @outPorts =
      command: new noflo.Port 'string'

    @inPorts.distance.on 'data', (data) =>
      return unless @outPorts.command.isAttached()
      @command.arg = data
      @outPorts.command.send @command

exports.getComponent = -> new Forward