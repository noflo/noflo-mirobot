noflo = require 'noflo'

class ProcessCommands extends noflo.Component
  description: 'Processes and stores commands to send to Mirobot.'
  icon: 'pencil'

  constructor: ->
    @commands = []
    @points = []
    @currentCommand = 0

    @inPorts =
      commands: new noflo.ArrayPort 'object'
      points: new noflo.Port 'object'
      next: new noflo.Port 'bang'

    @outPorts =
      command: new noflo.Port 'object'

    @inPorts.commands.on 'data', (cmd, i) =>
      @commands[i] = cmd

    # FIXME
    @inPorts.points.on 'data', (data) =>
      @points = data.items

    @inPorts.next.on 'data', () =>
      return unless @outPorts.command.isAttached()
      @outPorts.command.send @commands[@currentCommand]
      @currentCommand += 1
      # Finished all the commands, so stop it
      if @currentCommand >= @commands.length
        @commands = []
        @currentCommand = 0

  shutdown: ->
    # ??

exports.getComponent = -> new ProcessCommands
