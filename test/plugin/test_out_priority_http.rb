require 'helper'

class PriorityHttpOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
  ]

  def create_driver(conf = CONFIG)
    Fluent::Test::OutputTestDriver.new(Fluent::PriorityHttpOutput).configure(conf)
  end

  def test_emit
    stub_post = stub_request(:post, 'example.com').with(
      body: {
        a: 1,
        b: 2
      }.to_json
    )

    d = create_driver
    d.run do
      d.emit(a: 1, b: 2)
    end

    assert_requested(stub_post)
  end
end
