exec = require 'executive'

describe 'cake-mocha', ->
  it 'should add tasks', ->
    {stdout} = yield exec 'cake', cwd: __dirname
    stdout.should.contain 'static-server'
    stdout.should.contain 'test'
    stdout.should.contain 'test:ci'
    stdout.should.contain 'test:watch'
