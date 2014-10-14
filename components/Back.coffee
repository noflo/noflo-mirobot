noflo = require 'noflo'

class Back extends noflo.Component
  description: 'Send a back direction command.'
  icon: 'backward'

  constructor: ->
    @command =
      cmd: 'back'
      arg: null

    @inPorts =
      distance: new noflo.Port 'number'
    @outPorts =
      command: new noflo.Port 'string'

    @inPorts.distance.on 'data', (data) =>
      return unless @outPorts.command.isAttached()
      @command.arg = data
      @outPorts.command.send @command

exports.getComponent = -> new Back