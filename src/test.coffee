module.exports = (opts) ->
  (task) ->
    task 'test', 'Run tests', ['build', 'static-server'], (opts) ->
      bail     = opts.bail     ? true
      coverage = opts.coverage ? false
      grep     = opts.grep     ? ''
      test     = opts.test     ? 'test/ test/server/ test/browser/'
      verbose  = opts.verbose  ? ''

      bail    = '--bail' if bail
      grep    = "--grep #{opts.grep}" if grep
      verbose = 'DEBUG=nightmare VERBOSE=true CROWDSTART_DEBUG=1' if verbose

      if coverage
        bin = 'istanbul --print=none cover _mocha --'
      else
        bin = 'mocha'

      {status} = yield exec.interactive "NODE_ENV=test CROWDSTART_KEY='' CROWDSTART_ENDPOINT='' #{verbose}
            #{bin}
            --colors
            --reporter spec
            --timeout 10000000
            --compilers coffee:coffee-script/register
            --require co-mocha
            --require postmortem/register
            #{bail}
            #{grep}
            #{test}"

      server.close()
      process.exit status if opts.ci
