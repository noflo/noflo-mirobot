noflo = require 'noflo'

class TSP extends noflo.Component
  description: 'Ordenates points based on the minimum distance between them.'
  icon: 'code-fork'

  constructor: ->
    @points = []

    @inPorts =
      points: new noflo.Port 'object'

    @outPorts =
      points: new noflo.Port 'object'

    @inPorts.points.on 'data', (data) =>
      return unless @outPorts.points.isAttached()
      return unless data.items.length != 0
      @points = data.items
      @tspGreedy()
      @outPorts.points.send @points

  distance: (from, to) =>
    dx = @points[to].x - @points[from].x
    dy = @points[to].y - @points[from].y
    return Math.sqrt(dx*dx + dy*dy)

  # Inspired by https://code.google.com/p/google-maps-tsp-solver/
  tspGreedy: =>
    current = 0
    currentDistance = 0
    lastNode = 0
    visited = (false for i in [0...@points.length])
    bestPath = (0 for i in [0...@points.length])
    for step in [0...@points.length-1]
      visited[current] = true
      bestPath[step] = current
      nearest = 999999
      near = -1
      for next in [1...@points.length]
        if !visited[next] && ((@distance current, next) < nearest)
          nearest = @distance current, next
          near = next
      currentDistance += @distance current, near
      current = near
    bestPath[@points.length-1] = current
    @points = (@points[i] for i in bestPath)

exports.getComponent = -> new TSP