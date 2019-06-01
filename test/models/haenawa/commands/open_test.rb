require 'test_helper'

class OpenTest < ActiveSupport::TestCase
  def test_validate_target_allow_uri
    step = Step.new(step_no: 1, command: 'open', target: 'http://www.example.com', value: '')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_target_do_not_allow_blank
    step = Step.new(step_no: 1, command: 'open', target: '', value: '')
    step.step_command.validate
    expected = %w(対象エレメントの指定は必須です。対象エレメントの指定例をご参考ください。)
    assert_equal(expected, step.errors.full_messages)
  end

  def test_validate_target_require_uri
    step = Step.new(step_no: 1, command: 'open', target: ':', value: '')
    step.step_command.validate
    expected = %w(対象エレメントの指定は正しくありません。対象エレメントの指定例をご参考ください。)
    assert_equal(expected, step.errors.full_messages)
  end
end
