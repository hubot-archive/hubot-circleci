chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'

expect = chai.expect

describe 'circle-ci', ->
  beforeEach ->
    @robot =
      respond: sinon.spy()
      hear: sinon.spy()

    # require('../src/circle-ci')(@robot)


