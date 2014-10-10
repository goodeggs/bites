wd = require 'wd'
chai = require 'chai'
fibrous = require 'fibrous'
settings = require '../settings'

global.expect = chai.expect

before ->
  @browser = wd.promiseChainRemote()

  if settings.verbose
    @browser
      .on 'status', (info) ->
        console.log info
      .on 'command', (eventType, command, response) ->
        console.log 'wd', eventType, command, (response || '')

before ->
  @timeout 5000
  @browser
    .init
      browserName: settings.browser
    .configureHttp
      baseUrl: settings.devServerUrl()
    .sync.nodeify()

after ->
  @browser.sync.quit()
