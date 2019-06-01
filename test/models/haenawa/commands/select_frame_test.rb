require 'test_helper'

class SelectFrameTest < ActiveSupport::TestCase
  def test_switch_to_frame_by_index
    step = Step.new(step_no: 1, command: 'selectFrame', target: 'index=0', value: '')
    partial = step.step_command.render

    assert_partial_string_without_indent(<<EOS, partial)
assert has_selector?("iframe")
iframes = all(:css, "iframe")
switch_to_frame(iframes[0])
EOS
  end

  def test_switch_to_frame_by_relative_parent
    step = Step.new(step_no: 1, command: 'selectFrame', target: 'relative=parent', value: '')
    partial = step.step_command.render

    assert_partial_string_without_indent(<<EOS, partial)
switch_to_frame(:parent)
EOS
  end

  def test_switch_to_frame_by_relative_invalid
    step = Step.new(step_no: 1, command: 'selectFrame', target: 'relative=invalid', value: '')
    partial = step.step_command.render

    assert_partial_string_without_indent(<<EOS, partial)
raise "サポートしていない対象エレメントです。| selectFrame | relative=invalid |  |"
EOS
  end

  def test_validate_target_allow_index_strategy
    step = Step.new(step_no: 1, command: 'selectFrame', target: 'index=0', value: '')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_target_require_index
    step = Step.new(step_no: 1, command: 'selectFrame', target: 'index=', value: '')
    step.step_command.validate
    expected = %w(対象エレメントの指定は正しくありません。対象エレメントの指定例をご参考ください。)
    assert_equal(expected, step.errors.full_messages)
  end

  def test_validate_target_require_integer_index
    step = Step.new(step_no: 1, command: 'selectFrame', target: 'index=foo', value: '')
    step.step_command.validate
    expected = %w(対象エレメントの指定は正しくありません。対象エレメントの指定例をご参考ください。)
    assert_equal(expected, step.errors.full_messages)
  end

  def test_validate_target_allow_relative_strategy
    step = Step.new(step_no: 1, command: 'selectFrame', target: 'relative=parent', value: '')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_target_require_relative_id
    step = Step.new(step_no: 1, command: 'selectFrame', target: 'relative=', value: '')
    step.step_command.validate
    expected = %w(対象エレメントの指定は正しくありません。対象エレメントの指定例をご参考ください。)
    assert_equal(expected, step.errors.full_messages)
  end

  def test_validate_target_require_valid_relative_id
    step = Step.new(step_no: 1, command: 'selectFrame', target: 'relative=child', value: '')
    step.step_command.validate
    expected = %w(対象エレメントの指定は正しくありません。対象エレメントの指定例をご参考ください。)
    assert_equal(expected, step.errors.full_messages)
  end

  def test_validate_target_do_not_allow_blank
    step = Step.new(step_no: 1, command: 'selectFrame', target: '', value: '')
    step.step_command.validate
    expected = %w(対象エレメントの指定は必須です。対象エレメントの指定例をご参考ください。)
    assert_equal(expected, step.errors.full_messages)
  end
end
