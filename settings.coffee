convict = require 'convict'

settings = convict
  port:
    doc: "Localhost port dev server should listen on"
    format: 'port'
    default: 8000
    env: 'PORT'

  verbose:
    doc: "Dial the console logging up to 11"
    format: Boolean
    default: false
    env: 'VERBOSE'

  seleniumServer:
    port:
      format: 'port'
      default: 4444
      env: 'SELENIUM_SERVER_PORT'

  browser:
    doc: "Run tests in this browser"
    format: ['chrome', 'firefox', 'phantomjs']
    default: 'chrome'
    env: 'BROWSER'

  optimizeAssets:
    doc: "Minimize built css and js"
    format: Boolean
    default: false

.validate()
.get()

settings.devServerUrl = ->
  "http://localhost:#{@port}"

module.exports = settings
