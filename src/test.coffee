module.exports = (opts) ->
  task 'test', 'Run tests', (opts) ->
    bail     = opts.bail     ? true
    coverage = opts.coverage ? false
    grep     = opts.grep     ? ''
    test     = opts.test     ? 'test/'
    verbose  = opts.verbose  ? ''

    if opts.requireBuild
      yield invoke 'build'

    if opts.serveStatic
      yield invoke 'static-server', opts.serveStatic

    bin     = 'mocha'
    bail    = '--bail' if bail
    grep    = "--grep #{opts.grep}" if grep

    # Default env variables for tests
    env =
      NODE_ENV: 'test'

    env.VERBOSE = 'true' if verbose

    # Setup addons to have mocha to require
    addons = [
      '--compilers coffee:coffee-script/register'
      '--require co-mocha'
    ]

    # Coverage configuration
    if coverage
      bin = 'istanbul --print=none cover _mocha --'
      addons.push '--require coffee-coverage/register-istanbul'
    else
      addons.push '--require postmortem/register'

    # Update env with anything passed
    for k,v of opts.env
      env[k] = v

    # Generate env exports
    env = (k + '=' + v for k,v of env).join ' '

    # Build mocha command
    cmd = "#{env} #{bin}
           --colors
           --reporter spec
           --timeout 10000000
           #{addons.join ' '}
           --recursive
           #{bail}
           #{grep}
           #{test}"

    # Run tests and capture status
    {status} = yield exec.interactive cmd

    # Close server
    server.close() if opts.serveStatic

    # Exit with test status if non-zero
    process.exit status if status
