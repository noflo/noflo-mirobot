noflo = require 'noflo'

class ProcessCommands extends noflo.Component
  description: 'Processes and stores commands to send to Mirobot.'
  icon: 'pencil'

  constructor: ->
    @commands = []
    @points = []
    @currentCommand = 0
    @currentCommandArray = 0

    @inPorts =
      commands: new noflo.ArrayPort 'object'
      points: new noflo.Port 'object'
      next: new noflo.Port 'bang'

    @outPorts =
      command: new noflo.Port 'object'
      path: new noflo.Port 'object'

    @inPorts.commands.on 'data', (cmd, i) =>
      @commands[i] = cmd

    @inPorts.points.on 'data', (data) =>
      if data.items?
        @points = data.items
      else
        @points = data

    @inPorts.next.on 'data', () =>
      return unless @outPorts.command.isAttached()
      path = []

      if @commands[@currentCommand] instanceof Array
        @outPorts.command.send @commands[@currentCommand][@currentCommandArray]
        console.log 'HERE', @currentCommandArray, @commands[@currentCommand].length
        if @currentCommandArray < @commands[@currentCommand].length
          path.push @points[@currentCommandArray]
          path.push @points[@currentCommandArray+1]
          console.log path
          @outPorts.path.send path
          @currentCommandArray += 1
        if @currentCommandArray > @commands[@currentCommand].length
          console.log 'Mirobot finished array'
          @currentCommandArray = 0
          @currentCommand +=1
      else
        @outPorts.command.send @commands[@currentCommand]
        @currentCommand += 1

      if @currentCommand >= @commands.length
        console.log 'Mirobot finished all commands'
        @commands = []
        @currentCommand = 0
        @currentCommandArray = 0

  shutdown: ->
    # ??

exports.getComponent = -> new ProcessCommands
