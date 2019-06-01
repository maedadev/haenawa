require 'test_helper'

class WaitTest < ActiveSupport::TestCase
  def test_wait_for_element_present_by_id
    attrs = {
      command: 'waitForElementPresent',
      target: 'id=example'
    }
    step = create(:step, :for_build_history, attrs)
    partial = step.step_command.render

    assert_partial_string_without_indent(<<EOS, partial)
first(:id, "example")
EOS
  end

  def test_wait_for_element_present_by_xpath_short
    attrs = {
      command: 'waitForElementPresent',
      target: '//example'
    }
    step = create(:step, :for_build_history, attrs)
    partial = step.step_command.render

    assert_partial_string_without_indent(<<EOS, partial)
first(:xpath, "//example")
EOS
  end

  def test_wait_for_element_present_by_css
    attrs = {
      command: 'waitForElementPresent',
      target: 'css=.example'
    }
    step = create(:step, :for_build_history, attrs)
    partial = step.step_command.render

    assert_partial_string_without_indent(<<EOS, partial)
first(:css, ".example")
EOS
  end

  def test_wait_for_element_present_by_link
    attrs = {
      command: 'waitForElementPresent',
      target: 'link=example'
    }
    step = create(:step, :for_build_history, attrs)
    partial = step.step_command.render

    assert_partial_string_without_indent(<<EOS, partial)
first(:link, "example")
EOS
  end

  def test_wait_for_element_present_by_haenawa_label
    attrs = {
      command: 'waitForElementPresent',
      target: 'haenawaLabel=example'
    }
    step = create(:step, :for_build_history, attrs)
    partial = step.step_command.render

    assert_partial_string_without_indent(<<EOS, partial)
first(:field, "example")
EOS
  end

  def test_wait_for_element_present_unsupported_target
    step = Step.new(step_no: 1, command: 'waitForElementPresent', target: 'unsupported=example', value: '')
    partial = step.step_command.render

    assert_partial_string_without_indent(<<EOS, partial)
raise "サポートしていない対象エレメントです。| waitForElementPresent | unsupported=example |  |"
EOS
  end

  def test_wait_for_popup_by__blank
    step = Step.new(step_no: 1, command: 'waitForPopUp', target: '_blank', value: '200')
    partial = step.step_command.render

    assert_partial_string_without_indent(<<EOS, partial)
sleep 1
EOS
  end

  def test_wait_for_popup_by_value
    step = Step.new(step_no: 1, command: 'waitForPopUp', target: '', value: '1500')
    partial = step.step_command.render

    assert_partial_string_without_indent(<<EOS, partial)
sleep 2
EOS
  end

  def test_validate_target_allow_id_strategy
    step = Step.new(step_no: 1, command: 'waitForElementPresent', target: 'id=example', value: '')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_target_allow_xpath_strategy
    step = Step.new(step_no: 1, command: 'waitForElementPresent', target: 'xpath=//example', value: '')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_target_allow_xpath_short_strategy
    step = Step.new(step_no: 1, command: 'waitForElementPresent', target: '//example', value: '')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_target_allow_css_strategy
    step = Step.new(step_no: 1, command: 'waitForElementPresent', target: 'css=#example', value: '')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_target_allow_link_strategy
    step = Step.new(step_no: 1, command: 'waitForElementPresent', target: 'link=http://example.com', value: '')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_target_allow_link_text_strategy
    step = Step.new(step_no: 1, command: 'waitForElementPresent', target: 'linkText=example', value: '')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_target_allow_name_strategy
    step = Step.new(step_no: 1, command: 'waitForElementPresent', target: 'name=example', value: '')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_target_allow_haenawa_label_strategy
    step = Step.new(step_no: 1, command: 'waitForElementPresent', target: 'haenawaLabel=example', value: '')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_target_allow__blank
    step = Step.new(step_no: 1, command: 'waitForPopup', target: '_blank', value: '')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_target_do_not_allow_invalid_strategy
    step = Step.new(step_no: 1, command: 'waitForElementPresent', target: 'invalid=example', value: '')
    step.step_command.validate
    expected = %w(対象エレメントの指定は正しくありません。対象エレメントの指定例をご参考ください。)
    assert_equal(expected, step.errors.full_messages)
  end

  def test_validate_target_require_strategy_and_locator
    step = Step.new(step_no: 1, command: 'waitForElementPresent', target: '=', value: '')
    step.step_command.validate
    expected = %w(対象エレメントの指定は正しくありません。対象エレメントの指定例をご参考ください。)
    assert_equal(expected, step.errors.full_messages)
  end

  def test_validate_target_require_strategy
    step = Step.new(step_no: 1, command: 'waitForElementPresent', target: '=example', value: '')
    step.step_command.validate
    expected = %w(対象エレメントの指定は正しくありません。対象エレメントの指定例をご参考ください。)
    assert_equal(expected, step.errors.full_messages)
  end

  def test_validate_target_require_locator
    step = Step.new(step_no: 1, command: 'waitForElementPresent', target: 'id=', value: '')
    step.step_command.validate
    expected = %w(対象エレメントの指定は正しくありません。対象エレメントの指定例をご参考ください。)
    assert_equal(expected, step.errors.full_messages)
  end

  def test_validate_target_do_not_allow_blank
    step = Step.new(step_no: 1, command: 'waitForElementPresent', target: '', value: '')
    step.step_command.validate
    expected = %w(対象エレメントの指定は必須です。対象エレメントの指定例をご参考ください。)
    assert_equal(expected, step.errors.full_messages)
  end

  def test_validate_value_allow_integer
    step = Step.new(step_no: 1, command: 'waitForElementPresent', target: 'id=example', value: '42')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_value_allow_float
    step = Step.new(step_no: 1, command: 'waitForElementPresent', target: 'id=example', value: '42.0')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_value_allow_blank
    step = Step.new(step_no: 1, command: 'waitForElementPresent', target: 'id=example', value: '')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_value_do_not_allow_non_number
    step = Step.new(step_no: 1, command: 'waitForElementPresent', target: 'id=example', value: 'Two seconds')
    step.step_command.validate
    expected = %w(値の指定は正しくありません。値の指定例をご参考ください。)
    assert_equal(expected, step.errors.full_messages)
  end

  def test_target_interpolation
    attrs = {
      command: 'waitForElementPresent',
      target: 'link=%{project_name} (%{project_id}), %{scenario_name} (%{scenario_id}), Build Number: %{build_history_id}, Device: %{build_history_device}, Jenkins BUILD_NUMBER: %{build_sequence_code}'
    }
    step = create(:step, :for_build_history, attrs)
    partial = step.step_command.render
    build_history_id = step.steppable.id
    scenario_id = step.steppable.scenario.id
    project_id = step.steppable.scenario.project.id
    build_sequence_code = step.steppable.build_sequence_code

    assert_partial_string_without_indent(<<"EOS", partial)
first(:link, "Test Project (#{project_id}), Test Scenario (#{scenario_id}), Build Number: #{build_history_id}, Device: ie, Jenkins BUILD_NUMBER: #{build_sequence_code}")
EOS
  end

  def test_validate_target_do_now_allow_invalid_placeholder
    attrs = {
      command: 'waitForElementPresent',
      target: 'id=%{invalid}'
    }
    step = create(:step, :for_v2_scenario, attrs)
    step.step_command.validate
    expected = %w(対象エレメントのプレースホルダ指定は正しくありません。対象エレメントの指定例をご参考ください。)
    assert_equal(expected, step.errors.full_messages)
  end
end
