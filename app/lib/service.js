
'use strict'

module.exports = (server) => {
  server.start((err) => {
    if (err) {
      throw err
    }
    console.log('Server running at:', server.info.uri)
  })

  function shutdown () {
    server.stop(() => console.log('shutdown successful'))
  }

  process
    .once('SIGINT', shutdown)
    .once('SIGTERM', shutdown)
}
