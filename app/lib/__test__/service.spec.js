/* eslint-env node, mocha */
'use strict'

const expect = require('chai').expect
const sinon = require('sinon')
const proxyquire = require('proxyquire')

describe('Server: Startup', () => {
  let entry
  let startStub
  beforeEach(function () {
    entry = require('./../service')
    startStub = sinon.stub()
  })

  it('should call start method', function () {
    entry({ start: startStub })
    expect(startStub.callCount).to.equal(1)
  })
})
