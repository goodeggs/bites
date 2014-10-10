wd = require 'wd'
chai = require 'chai'
asPromsed = require 'chai-as-promised'
settings = require '../settings'

asPromsed.transferPromiseness = wd.transferPromiseness

chai
  .use asPromsed
  .should()

before ->
  @timeout 5000
  @browser = wd.promiseChainRemote()
    .init
      browserName: settings.browser
    .configureHttp
      baseUrl: settings.devServerUrl()

after ->
  @browser.quit()
