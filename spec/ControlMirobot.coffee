noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  ControlMirobot = require '../components/ControlMirobot.coffee'
else
  ControlMirobot = require 'noflo-mirobot/components/ControlMirobot.js'

describe 'ControlMirobot component', ->
  c = null
  ins = null
  out = null
  beforeEach ->
    c = ControlMirobot.getComponent()
    ins = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    c.inPorts.lib.attach ins
    c.outPorts.path.attach out

  describe 'when instantiated', ->
    it 'should have an lib port', ->
      chai.expect(c.inPorts.lib).to.be.an 'object'
    it 'should have an path outport', ->
      chai.expect(c.outPorts.path).to.be.an 'object'
