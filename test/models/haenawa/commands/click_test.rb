require 'test_helper'

class ClickTest < ActiveSupport::TestCase

  def test_click_by_id
    attrs = {
      command: 'click',
      target: 'id=example'
    }
    step = create(:step, :for_build_history, attrs)
    partial = step.step_command.render


    assert_partial_string_without_indent(<<EOS, partial)
first(:id, "example").click
EOS
  end

  def test_click_by_xpath
    attrs = {
      command: 'click',
      target: 'xpath=//example'
    }
    step = create(:step, :for_build_history, attrs)
    partial = step.step_command.render

    assert_partial_string_without_indent(<<EOS, partial)
first(:xpath, "//example").click
EOS
  end

  def test_click_by_xpath_short
    attrs = {
      command: 'click',
      target: '//example'
    }
    step = create(:step, :for_build_history, attrs)
    partial = step.step_command.render

    assert_partial_string_without_indent(<<EOS, partial)
first(:xpath, "//example").click
EOS
  end

  def test_click_by_css
    attrs = {
      command: 'click',
      target: 'css=.example'
    }
    step = create(:step, :for_build_history, attrs)
    partial = step.step_command.render

    assert_partial_string_without_indent(<<EOS, partial)
first(:css, ".example").click
EOS
  end

  def test_click_by_link
    attrs = {
      command: 'click',
      target: 'link=example'
    }
    step = create(:step, :for_build_history, attrs)
    partial = step.step_command.render

    assert_partial_string_without_indent(<<EOS, partial)
first(:link, "example")
EOS
  end

  def test_click_by_link_text
    attrs = {
      command: 'click',
      target: 'linkText=example'
    }
    step = create(:step, :for_build_history, attrs)
    partial = step.step_command.render

    assert_partial_string_without_indent(<<EOS, partial)
first(:link, "example").click
EOS
  end

  def test_click_by_name
    attrs = {
      command: 'click',
      target: 'name=example'
    }
    step = create(:step, :for_build_history, attrs)
    partial = step.step_command.render
    assert_partial_string_without_indent(<<EOS, partial)
first(:css, '[name="example"]').click
EOS
  end

  def test_click_by_haenawa_label
    attrs = {
      command: 'click',
      target: 'haenawaLabel=example'
    }
    step = create(:step, :for_build_history, attrs)
    partial = step.step_command.render
    assert_partial_string_without_indent(<<EOS, partial)
first(:field, "example").click
EOS
  end

  def test_click_accept_confirm
    build_history = create(:build_history)
    create(:step, step_no: 1, command: 'chooseOkOnNextConfirmation', steppable: build_history)
    step = create(:step, step_no: 2, command: 'click', target: 'id=example', steppable: build_history)
    partial = step.step_command.render

    assert_partial_string_without_indent(<<EOS, partial)
accept_confirm do
first(:id, "example").click
end
EOS
  end

  def test_click_dismiss_confirm
    build_history = create(:build_history)
    create(:step, step_no: 1, command: 'chooseCancelOnNextConfirmation', steppable: build_history)
    step = create(:step, step_no: 2, command: 'click', target: 'id=example', steppable: build_history)
    partial = step.step_command.render

    assert_partial_string_without_indent(<<EOS, partial)
dismiss_confirm do
first(:id, "example").click
end
EOS
  end

  def test_click_unsupported_target
    step = Step.new(step_no: 1, command: 'click', target: 'unsupported=example', value: '')
    partial = step.step_command.render

    assert_partial_string_without_indent(<<EOS, partial)
raise "サポートしていない対象エレメントです。| click | unsupported=example |  |"
EOS
  end

  def test_validate_target_allow_id_strategy
    step = Step.new(step_no: 1, command: 'click', target: 'id=example', value: '')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_target_allow_xpath_strategy
    step = Step.new(step_no: 1, command: 'click', target: 'xpath=//example', value: '')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_target_allow_xpath_short_strategy
    step = Step.new(step_no: 1, command: 'click', target: '//example', value: '')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_target_allow_css_strategy
    step = Step.new(step_no: 1, command: 'click', target: 'css=#example', value: '')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_target_allow_link_strategy
    step = Step.new(step_no: 1, command: 'click', target: 'link=http://example.com', value: '')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_target_allow_link_text_strategy
    step = Step.new(step_no: 1, command: 'click', target: 'linkText=example', value: '')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_target_allow_name_strategy
    step = Step.new(step_no: 1, command: 'click', target: 'name=example', value: '')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_target_allow_haenawa_label_strategy
    step = Step.new(step_no: 1, command: 'click', target: 'haenawaLabel=example', value: '')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_target_do_not_allow_invalid_strategy
    step = Step.new(step_no: 1, command: 'click', target: 'invalid=example', value: '')
    step.step_command.validate
    expected = %w(対象エレメントの指定は正しくありません。対象エレメントの指定例をご参考ください。)
    assert_equal(expected, step.errors.full_messages)
  end

  def test_validate_target_require_strategy_and_locator
    step = Step.new(step_no: 1, command: 'click', target: '=', value: '')
    step.step_command.validate
    expected = %w(対象エレメントの指定は正しくありません。対象エレメントの指定例をご参考ください。)
    assert_equal(expected, step.errors.full_messages)
  end

  def test_validate_target_require_strategy
    step = Step.new(step_no: 1, command: 'click', target: '=example', value: '')
    step.step_command.validate
    expected = %w(対象エレメントの指定は正しくありません。対象エレメントの指定例をご参考ください。)
    assert_equal(expected, step.errors.full_messages)
  end

  def test_validate_target_require_locator
    step = Step.new(step_no: 1, command: 'click', target: 'id=', value: '')
    step.step_command.validate
    expected = %w(対象エレメントの指定は正しくありません。対象エレメントの指定例をご参考ください。)
    assert_equal(expected, step.errors.full_messages)
  end

  def test_validate_target_do_not_allow_blank
    step = Step.new(step_no: 1, command: 'click', target: '', value: '')
    step.step_command.validate
    expected = %w(対象エレメントの指定は必須です。対象エレメントの指定例をご参考ください。)
    assert_equal(expected, step.errors.full_messages)
  end

  def test_target_interpolation
    attrs = {
      command: 'click',
      target: 'link=%{project_name} (%{project_id}), %{scenario_name} (%{scenario_id}), Build Number: %{build_history_id}, Device: %{build_history_device}, Jenkins BUILD_NUMBER: %{build_sequence_code}'
    }
    step = create(:step, :for_build_history, attrs)
    partial = step.step_command.render
    build_history_id = step.steppable.id
    scenario_id = step.steppable.scenario.id
    project_id = step.steppable.scenario.project.id
    build_sequence_code = step.steppable.build_sequence_code

    assert_partial_string_without_indent(<<"EOS", partial)
first(:link, "Test Project (#{project_id}), Test Scenario (#{scenario_id}), Build Number: #{build_history_id}, Device: ie, Jenkins BUILD_NUMBER: #{build_sequence_code}").click
EOS
  end

  def test_validate_target_do_now_allow_invalid_placeholder
    attrs = {
      command: 'click',
      target: 'id=%{invalid}',
      value: 'example'
    }
    step = create(:step, :for_v2_scenario, attrs)
    step.step_command.validate
    expected = %w(対象エレメントのプレースホルダ指定は正しくありません。対象エレメントの指定例をご参考ください。)
    assert_equal(expected, step.errors.full_messages)
  end
end

