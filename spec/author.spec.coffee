require './spec_helper'

describe 'author page', ->
  before ->
    @browser.sync.get '/authors/alex_gorbatchev/'

  it 'shows their name', ->
    @browser
      .elementByCss '.author'
      .text().should.eventually.contain 'Alex'
      .sync.nodeify()

  it 'lists their posts', ->
    @browser
      .elementByCss '.entry-title'
      .text().should.eventually.contain 'Comparing Node.js Promises'
      .sync.nodeify()
