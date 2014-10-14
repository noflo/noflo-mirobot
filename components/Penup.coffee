noflo = require 'noflo'

class Penup extends noflo.Component
  description: 'Send a penup command.'
  icon: 'level-up'

  constructor: ->
    @command =
      cmd: 'penup'

    @inPorts =
      penup: new noflo.Port 'bang'
    @outPorts =
      command: new noflo.Port 'string'

    @inPorts.penup.on 'data', (data) =>
      return unless @outPorts.command.isAttached()
      @outPorts.command.send @command

exports.getComponent = -> new Penup