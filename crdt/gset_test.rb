require 'test/unit'
require './gset'



class MyTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  # Fake test
  def test_all

    gset = GSet.new
    gset2 = GSet.new

    gset.add('bob')
    gset.add('raylene')

    gset2.add('bob')

    assert(gset.include?('bob'))
    assert(!gset2.include?('raylene'))

    gset3 = GSet.new
    gset3.merge gset
    gset3.merge gset2

    assert(gset3.include?('bob'))
    assert(gset3.include?('raylene'))

    json_value = gset3.to_json

    puts json_value

    gset4 = GSet.new
    gset4 = gset4.merge_json(json_value)

    assert(gset4.include?('bob'))
    assert(gset4.include?('raylene'))

    marshaled_value = gset3.to_marshal

    puts marshaled_value

    gset5 = GSet.new
    gset5 = gset5.merge_marshal(marshaled_value)

    assert(gset5.include?('bob'))
    assert(gset5.include?('raylene'))

  end
end