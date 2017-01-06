noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-mirobot'

describe 'ControlMirobot component', ->
  c = null
  ins = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'mirobot/ControlMirobot', (err, instance) ->
      return done err if err
      c = instance
      ins = noflo.internalSocket.createSocket()
      c.inPorts.lib.attach ins
      done()
  beforeEach ->
    out = noflo.internalSocket.createSocket()
    c.outPorts.path.attach out
  afterEach ->
    c.outPorts.path.detach out

  describe 'when instantiated', ->
    it 'should have an lib port', ->
      chai.expect(c.inPorts.lib).to.be.an 'object'
    it 'should have an path outport', ->
      chai.expect(c.outPorts.path).to.be.an 'object'
