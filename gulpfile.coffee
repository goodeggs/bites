gulp = require 'gulp'
gutil = require 'gulp-util'
settings = require './settings'

gulp.task 'generate', require './metalsmith'

gulp.task 'serve:dev', (done) ->
  connect = require 'connect'
  serveStatic = require 'serve-static'

  connect()
  .use serveStatic('build')
  .listen settings.port, done

gulp.task 'dev', ['generate', 'serve:dev']
