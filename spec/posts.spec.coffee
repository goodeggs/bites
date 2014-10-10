require './spec_helper'

describe 'post listings page', ->
  before ->
    @browser.sync.get '/'

  it 'has a title', ->
    expect(@browser.sync.title()).to.equal 'Bites from Good Eggs'
