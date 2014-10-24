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
      @url.should.contain '/posts/'

    it 'has a trailing slash', ->
      @url.should.match /\/$/

describe 'bfcache post', ->
  before ->
    @browser.sync.get '/posts/you-forgot-about-bfcache/'

  it 'has generated title and author markup', ->
    @browser
      .elementByCss '.entry-title'
      .text().should.become "You Forgot About bfcache!"

      .elementByCss '.entry-author-name'
      .text().should.eventually.contain "Brian"
      .sync.nodeify()

  it 'has syntax highlighting', ->
    @browser
      .elementByCss 'code .hljs-keyword'
      .getComputedCss('color').should.eventually.be.colored '#aa0d91'
      .sync.nodeify()
