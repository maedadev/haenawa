require 'test_helper'

class BuildHistoryTest < ActiveSupport::TestCase
  def test_build_sequence_code
    assert_equal('42', create(:build_history).build_sequence_code)
  end

  def test_build_sequence_default_value
    bh = create(:build_history, build_sequence_code: nil)
    assert('forty-two', bh.build_sequence_code)
  end
end
