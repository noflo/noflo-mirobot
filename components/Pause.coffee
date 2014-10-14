noflo = require 'noflo'

class Pause extends noflo.Component
  description: 'Send a pause command.'
  icon: 'pause'

  constructor: ->
    @command =
      cmd: 'pause'

    @inPorts =
      pause: new noflo.Port 'bang'
    @outPorts =
      command: new noflo.Port 'string'

    @inPorts.pause.on 'data', (data) =>
      return unless @outPorts.command.isAttached()
      @outPorts.command.send @command

exports.getComponent = -> new Pause