gulp = require 'gulp'
gutil = require 'gulp-util'

gulp.task 'generate', require './metalsmith'

gulp.task 'serve:dev', (done) ->
  connect = require 'connect'
  serveStatic = require 'serve-static'
  http = require 'http'

  servers.dev ?= connect()
  .use serveStatic('build')
  .listen settings.port, done
