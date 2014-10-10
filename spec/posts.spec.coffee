require './spec_helper'

describe 'post listings page', ->
  before ->
    @browser.get '/'

  it 'has a title', ->
    @browser.title().should.become 'Bites from Good Eggs'
