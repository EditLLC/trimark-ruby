require 'test_helper'

class TrimarkTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Trimark::VERSION
  end
end
