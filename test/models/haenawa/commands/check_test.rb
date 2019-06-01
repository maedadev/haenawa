require 'test_helper'

class CheckTest < ActiveSupport::TestCase
  def test_check_by_haenawa_label
    attrs = {
      command: 'check',
      target: 'haenawaLabel=example'
    }
    step = create(:step, :for_build_history, attrs)
    partial = step.step_command.render
    assert_partial_string_without_indent(<<EOS, partial)
first(:field, "example").set(true)
EOS
  end

  def test_check_accept_confirm
    build_history = create(:build_history)
    create(:step, command: 'chooseOkOnNextConfirmation', step_no: 1, steppable: build_history)
    step = create(:step,  command: 'check', target: 'id=example', step_no: 2, steppable: build_history)
    partial = step.step_command.render

    assert_partial_string_without_indent(<<EOS, partial)
accept_confirm do
first(:id, "example").set(true)
end
EOS
  end

  def test_check_dismiss_confirm
    build_history = create(:build_history)
    create(:step, step_no: 1, command: 'chooseCancelOnNextConfirmation', steppable: build_history)
    step = create(:step, step_no: 2, command: 'uncheck', target: 'id=example', steppable: build_history)
    partial = step.step_command.render

    assert_partial_string_without_indent(<<EOS, partial)
dismiss_confirm do
first(:id, "example").set(false)
end
EOS
  end

  def test_check_unsupported_target
    step = Step.new(step_no: 1, command: 'check', target: 'unsupported=example', value: '')
    partial = step.step_command.render

    assert_partial_string_without_indent(<<EOS, partial)
raise "サポートしていない対象エレメントです。| check | unsupported=example |  |"
EOS
  end

  def test_validate_target_allow_id_strategy
    step = Step.new(step_no: 1, command: 'check', target: 'id=example', value: '')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_target_allow_xpath_strategy
    step = Step.new(step_no: 1, command: 'check', target: 'xpath=//example', value: '')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_target_allow_xpath_short_strategy
    step = Step.new(step_no: 1, command: 'check', target: '//example', value: '')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_target_allow_css_strategy
    step = Step.new(step_no: 1, command: 'check', target: 'css=#example', value: '')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_target_allow_link_strategy
    step = Step.new(step_no: 1, command: 'check', target: 'link=http://example.com', value: '')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_target_allow_link_text_strategy
    step = Step.new(step_no: 1, command: 'check', target: 'linkText=example', value: '')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_target_allow_name_strategy
    step = Step.new(step_no: 1, command: 'check', target: 'name=example', value: '')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_target_allow_haenawa_label_strategy
    step = Step.new(step_no: 1, command: 'check', target: 'haenawaLabel=example', value: '')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_target_do_not_allow_invalid_strategy
    step = Step.new(step_no: 1, command: 'check', target: 'invalid=example', value: '')
    step.step_command.validate
    expected = %w(対象エレメントの指定は正しくありません。対象エレメントの指定例をご参考ください。)
    assert_equal(expected, step.errors.full_messages)
  end

  def test_validate_target_require_strategy_and_locator
    step = Step.new(step_no: 1, command: 'check', target: '=', value: '')
    step.step_command.validate
    expected = %w(対象エレメントの指定は正しくありません。対象エレメントの指定例をご参考ください。)
    assert_equal(expected, step.errors.full_messages)
  end

  def test_validate_target_require_strategy
    step = Step.new(step_no: 1, command: 'check', target: '=example', value: '')
    step.step_command.validate
    expected = %w(対象エレメントの指定は正しくありません。対象エレメントの指定例をご参考ください。)
    assert_equal(expected, step.errors.full_messages)
  end

  def test_validate_target_require_locator
    step = Step.new(step_no: 1, command: 'check', target: 'id=', value: '')
    step.step_command.validate
    expected = %w(対象エレメントの指定は正しくありません。対象エレメントの指定例をご参考ください。)
    assert_equal(expected, step.errors.full_messages)
  end

  def test_validate_target_do_not_allow_blank
    step = Step.new(step_no: 1, command: 'check', target: '', value: '')
    step.step_command.validate
    expected = %w(対象エレメントの指定は必須です。対象エレメントの指定例をご参考ください。)
    assert_equal(expected, step.errors.full_messages)
  end

  def test_target_interpolation
    attrs = {
      command: 'check',
      target: 'name=project_%{project_id}_scenario_%{scenario_id}_build_%{build_history_id}_build_sequence_code_%{build_sequence_code}'
    }
    step = create(:step, :for_build_history, attrs)
    partial = step.step_command.render
    build_history_id = step.steppable.id
    scenario_id = step.steppable.scenario.id
    project_id = step.steppable.scenario.project.id
    build_sequence_code = step.steppable.build_sequence_code

    assert_partial_string_without_indent(<<"EOS", partial)
first(:css, '[name="project_#{project_id}_scenario_#{scenario_id}_build_#{build_history_id}_build_sequence_code_#{build_sequence_code}"]').set(true)
EOS
  end

  def test_validate_target_do_now_allow_invalid_placeholder
    attrs = {
      command: 'check',
      target: 'id=%{invalid}'
    }
    step = create(:step, :for_v2_scenario, attrs)
    step.step_command.validate
    expected = %w(対象エレメントのプレースホルダ指定は正しくありません。対象エレメントの指定例をご参考ください。)
    assert_equal(expected, step.errors.full_messages)
  end
end
