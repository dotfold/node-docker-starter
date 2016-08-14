
'use strict'

const yargs = require('yargs')
const args = yargs.usage('Usage: $0 <command> [options]')
    .describe('host', 'bind the server port')
    .help('h')
    .argv

const server = require('./lib/server')
require('./lib/service')(server(args))
