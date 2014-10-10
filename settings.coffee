convict = require 'convict'

settings = convict
  # Dev Server Settings
  port:
    doc: "Localhost port dev server should listen on"
    format: 'port'
    default: 8000
    env: 'PORT'

.validate()
.get()

settings.devServerUrl = ->
  "http://localhost:#{@port}"

module.exports = settings
