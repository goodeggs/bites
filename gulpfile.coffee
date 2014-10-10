gulp = require 'gulp'
gutil = require 'gulp-util'
settings = require './settings'
logProcess = require 'process-logger'

gulp.task 'clean', ->
  del = require 'del'
  del.sync ['build', 'release']

gulp.task 'generate', require './metalsmith'

servers =
  dev: null
  selenium: null
  shutdown: (done) ->
    @dev.close =>
      @selenium.kill()
      done?()

gulp.task 'serve:dev', (done) ->
  connect = require 'connect'
  serveStatic = require 'serve-static'

  servers.dev = connect()
  .use serveStatic('build')
  .listen settings.port, done

gulp.task 'serve:selenium', ->
  selenium = require 'selenium-standalone'
  tcpPort = require 'tcp-port-used'

  servers.selenium = selenium
    stdio: settings.verbose and 'pipe' or 'ignore'
    ['-port', settings.seleniumServer.port]

  if settings.verbose
    logProcess servers.selenium, prefix: '[selenium-server]'

  return tcpPort.waitUntilUsed(settings.seleniumServer.port, 500, 10000)

gulp.task 'spec', ['generate', 'serve:dev', 'serve:selenium'], (done) ->
  {spawn} = require 'child_process'
  mocha = spawn 'mocha', [
    '--compilers', 'coffee:coffee-script/register'
    '--reporter', 'spec'
    '--ui', 'mocha-fibers'
    'spec/*.spec.coffee'
  ]
  .on 'exit', (code) ->
    servers.shutdown ->
      done code or null

  logProcess mocha, prefix: settings.verbose and '[mocha]' or ''
  return null # don't return a stream

gulp.task 'dev', ['generate', 'serve:dev']
