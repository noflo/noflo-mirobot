noflo = require 'noflo'

class Array extends noflo.Component
  description: 'Array.'
  icon: 'pencil'

  constructor: ->
    @points = []

    @inPorts =
      send: new noflo.Port 'bang'
      clean: new noflo.Port 'bang'
      points: new noflo.Port 'object'

    @outPorts =
      array: new noflo.Port 'object'

    @inPorts.send.on 'data', () =>
      @outPorts.array.send @points

    @inPorts.clean.on 'data', () =>
      @points = []

    @inPorts.points.on 'data', (point) =>
      @points.push point

exports.getComponent = -> new Array
