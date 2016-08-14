/* eslint-env node, mocha */
'use strict'

const expect = require('chai').expect
const sinon = require('sinon')
const proxyquire = require('proxyquire')

describe('Server: Connection', () => {
  let server
  let connectionStub
  let routeStub
  beforeEach(function () {
    connectionStub = sinon.stub()
    routeStub = sinon.stub()
    server = proxyquire('./../server', {
      hapi: {
        Server: function () {
          return {
            connection: connectionStub,
            route: routeStub
          }
        }
      }
    })
  })

  it('should build the connection with the supplied port', function () {
    const args = { port: 'a'}
    const s = server(args)

    expect(connectionStub.calledOnce).to.be.true

    const lastArgs = connectionStub.lastCall.args[0]
    expect(lastArgs).to.have.property('port', 'a')
  })

  it('should build the connection with the default port', function () {
    // no port specified here
    const args = { foo: 'a' }
    const s = server(args)

    expect(connectionStub.calledOnce).to.be.true

    const lastArgs = connectionStub.lastCall.args[0]
    expect(lastArgs).to.have.property('port', 8800)
  })

  describe('Routes setup', () => {
    it('should build the correct number of routes', function () {
      const s = server({})

      expect(routeStub.callCount).to.equal(2)
    })
  })
})


