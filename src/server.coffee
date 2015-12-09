module.exports = (opts) ->
  opts.port    ?= process.env.PORT ? 3333
  opts.dir     ?= process.cwd() + '/test/fixtures'
  opts.message ?= 'Run static server for tests'
  opts.name    ?= 'static-server'

  task opts.name, opts.message, (cb) ->
    server.use (require 'serve-static') opts.dir
    server = require('http').createServer(server).listen opts.port, cb
