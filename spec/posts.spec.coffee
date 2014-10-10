require './spec_helper'

describe 'post listings page', ->
  before ->
    @browser.sync.get '/'

  it 'has a title', ->
    @browser
      .title().should.eventually.equal 'Bites from Good Eggs'
      .sync.nodeify()

  describe 'on a page with truncated articles', ->
    before ->
      @browser
        .elementByCss 'article.truncated'
        .isDisplayed().should.eventually.be.ok
        .sync.nodeify()

    it 'shows read more links for truncated articles', ->
      @browser
        .elementByCss 'article.truncated a.more'
        .isDisplayed().should.eventually.be.ok
        .sync.nodeify()
