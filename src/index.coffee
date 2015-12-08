module.exports = (opts = {}) ->
  (task) ->
    (require('./server')     opts) task
    (require('./test')       opts) task
    (require('./test-ci')    opts) task
    (require('./test-watch') opts) task
