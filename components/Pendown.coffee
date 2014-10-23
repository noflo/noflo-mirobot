noflo = require 'noflo'

class Pendown extends noflo.Component
  description: 'Send a pendown command.'
  icon: 'level-down'

  constructor: ->
    @command =
      cmd: 'pendown'

    @inPorts =
      pendown: new noflo.Port 'bang'
    @outPorts =
      command: new noflo.Port 'string'

    @inPorts.pendown.on 'data', (data) =>
      return unless @outPorts.command.isAttached()
      @outPorts.command.send @command

exports.getComponent = -> new Pendown