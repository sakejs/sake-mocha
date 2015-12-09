module.exports = (opts = {}) ->
  require('./server')     opts
  require('./test')       opts
  require('./test-ci')    opts
  require('./test-watch') opts
