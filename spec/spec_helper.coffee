wd = require 'wd'
chai = require 'chai'
asPromsed = require 'chai-as-promised'
settings = require '../settings'

asPromsed.transferPromiseness = wd.transferPromiseness

chai
  .use asPromsed
  .should()

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

after ->
  @browser.quit()
