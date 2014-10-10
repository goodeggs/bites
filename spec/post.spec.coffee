require './spec_helper'

describe 'post page', ->
  before ->
    @browser
      .get '/'
      .elementByCss('.entry-title a').click()
      .sync.nodeify()

  describe 'url', ->
    before ->
      @url = @browser.sync.url()

    it 'is nested in the /posts path', ->
      expect(@url).to.contain '/posts/'

    it 'has a trailing slash', ->
      expect(@url).to.match /\/$/
