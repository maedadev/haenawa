require 'test_helper'

class SetWindowSizeTest < ActiveSupport::TestCase
  def test_set_window_size
    step = Step.new(step_no: 1, command: 'setWindowSize', target: '320x240', value: '')
    partial = step.step_command.render

    assert_partial_string_without_indent(<<EOS, partial)
$device.resize_window(320, 240)
EOS
  end

  def test_validate_target_allow_window_dimensions
    step = Step.new(step_no: 1, command: 'setWindowSize', target: '1024x768', value: '')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_target_require_correct_format
    step = Step.new(step_no: 1, command: 'setWindowSize', target: '1024*768', value: '')
    step.step_command.validate
    expected = %w(対象エレメントの指定は正しくありません。対象エレメントの指定例をご参考ください。)
    assert_equal(expected, step.errors.full_messages)
  end

  def test_validate_target_do_not_allow_blank
    step = Step.new(step_no: 1, command: 'setWindowSize', target: '', value: '')
    step.step_command.validate
    expected = %w(対象エレメントの指定は必須です。対象エレメントの指定例をご参考ください。)
    assert_equal(expected, step.errors.full_messages)
  end
end
