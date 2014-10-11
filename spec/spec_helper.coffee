wd = require 'wd'
chai = require 'chai'
asPromised = require 'chai-as-promised'
fibrous = require 'fibrous'
settings = require '../settings'

asPromised.transferPromiseness = wd.transferPromiseness

chai
  .use asPromised
  .should()

global.fibrous = fibrous

before ->
  @browser = wd.promiseChainRemote()

  if settings.verbose
    @browser
      .on 'status', (info) ->
        console.log info
      .on 'command', (eventType, command, response) ->
        console.log 'wd', eventType, command, (response || '')

before ->
  @browser
    .init
      browserName: settings.browser
    .configureHttp
      baseUrl: settings.devServerUrl()
    .sync.nodeify()

after ->
  @browser.sync.quit()
