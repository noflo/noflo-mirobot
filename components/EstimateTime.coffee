noflo = require 'noflo'

costs =
  left: (arg) -> return (10*parseFloat(arg))/360 
  right: (arg) -> return (10*parseFloat(arg))/360 
  forward: (arg) -> return parseFloat(arg)/40
  back: (arg) -> return parseFloat(arg)/40
  penup: (arg) -> return 0.25
  pendown: (arg) -> return 0.25
      
###
Object {cmd: "left", arg: "6.3401917459099195", id: "chmqgad8id"}
Object {cmd: "forward", arg: "6.4031242374328485"}
Object {cmd: "right", arg: "51.34019174590991", id: "w61z4r3mi3"}
###

exports.getComponent = ->
  c = new noflo.Component
  c.inPorts.add 'commands', (event, payload) ->
    return unless event is 'data'
    commands = payload
    
    total = 0.0
    for command in commands
      func = costs[command.cmd]
      cost = func command.arg
      total += cost

    c.outPorts.out.send total
    
  c.outPorts.add 'out'
  c