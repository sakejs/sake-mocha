exec = require 'executive'

describe 'sake-mocha', ->
  it 'should add tasks', ->
    {stdout} = yield exec 'sake', cwd: __dirname
    stdout.should.contain 'test'
    stdout.should.contain 'test:ci'
