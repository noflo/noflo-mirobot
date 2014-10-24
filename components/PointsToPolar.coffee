noflo = require 'noflo'

# Converts from radians to degrees.
Math.degrees = (radians) ->
  return radians * 180 / Math.PI

class PointsToPolar extends noflo.Component
  description: 'Converts cartesian coordinates to polar coordinates.'
  icon: 'paint-brush'

  constructor: ->
    @mirobotAngle = 0
    @commands = []

    @inPorts =
      points: new noflo.Port 'object'

    @outPorts =
      polar: new noflo.Port 'object'

    @inPorts.points.on 'data', (data) =>
      return unless @outPorts.polar.isAttached()
      @mirobotAngle = 0
      points = data.items
      @parsePoints points
      @outPorts.polar.send @commands

  parsePoints: (start, end) =>
    if start? and end? and start.x? and end.x?
      @pathFinding(start, end)
    else if start instanceof Array
      for item, i in start
        continue unless item?
        if start[i+1]?
          @parsePoints item, start[i+1]

  pathFinding: (from, to) =>

    # Distance is a simple Pythagoras
    dx = to.x - from.x
    dy = to.y - from.y
    distance = Math.sqrt(dx*dx + dy*dy)

    # Calculate the angle
    arctangent = Math.atan2(dx, dy)
    angle = Math.degrees(arctangent)

    # Calculating the walking angle based on previous mirobot angle
    @walkingAngle =  angle - @mirobotAngle
    if @walkingAngle < 0
      @walkingAngle = @walkingAngle + 360

    @mirobotAngle = angle
    if @mirobotAngle >= 360
      @mirobotAngle = @mirobotAngle - 360
 
    commandDirection =
      cmd: null
      arg: null

    if @walkingAngle <= 180
      commandDirection.cmd = 'right'
      commandDirection.arg = @walkingAngle.toString()
    else
      commandDirection.cmd = 'left'
      commandDirection.arg = (360 - @walkingAngle).toString()
 
    commandForward =
      cmd: 'forward'
      arg: distance.toString()
 
    @commands.push commandDirection
    @commands.push commandForward

exports.getComponent = -> new PointsToPolar