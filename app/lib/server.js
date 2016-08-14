
// node_modules
const Hapi = require('hapi')
const Boom = require('boom')
const _ = require('lodash')

// Create a server with a host and port
const serverConfig = (opts) => {
  const server = new Hapi.Server()

  opts.host || delete opts.host
  const connectionConfig = Object.assign({}, {
    port: (opts.port || 8800)
  })

  server.connection(connectionConfig)

  server.route({
    method: 'GET',
    path: '/',
    handler: function (request, reply) {
      return reply(Boom.notFound('Resource does not exist'))
    }
  })

  server.route({
    method: 'GET',
    path: '/ping',
    handler: function (request, reply) {
      return reply('pong')
    }
  })

  return server
}

module.exports = serverConfig
