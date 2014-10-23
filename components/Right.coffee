noflo = require 'noflo'

class Right extends noflo.Component
  description: 'Send a right direction command.'
  icon: 'rotate-right'

  constructor: ->
    @command =
      cmd: 'right'
      arg: null

    @inPorts =
      right: new noflo.Port 'number'
    @outPorts =
      command: new noflo.Port 'string'

    @inPorts.right.on 'data', (data) =>
      return unless @outPorts.command.isAttached()
      @command.arg = data
      @outPorts.command.send @command

exports.getComponent = -> new Right