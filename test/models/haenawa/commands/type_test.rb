require 'test_helper'

class TypeTest < ActiveSupport::TestCase
  def test_type_by_id
    attrs = {
      command: 'type',
      target: %q|id=id-foo'bar"baz\quux#{hoge}hogehoge|,
      value: %q|value-foo'bar"baz\quux#{hoge}hogehoge|,
    }
    step = create(:step, :for_build_history, attrs)
    partial = step.step_command.render

    assert_partial_string_without_indent(<<'EOS', partial)
first(:id, "id-foo'bar\"baz\\quux\#{hoge}hogehoge").set("value-foo'bar\"baz\\quux\#{hoge}hogehoge")
EOS
  end

  def test_type_by_xpath
    attrs = {
      command: 'type',
      target: %q|xpath=id-foo'bar"baz\quux#{hoge}hogehoge|,
      value: %q|value-foo'bar"baz\quux#{hoge}hogehoge|
    }
    step = create(:step, :for_build_history, attrs)
    partial = step.step_command.render

    assert_partial_string_without_indent(<<'EOS', partial)
first(:xpath, "id-foo'bar\"baz\\quux\#{hoge}hogehoge").set("value-foo'bar\"baz\\quux\#{hoge}hogehoge")
EOS
  end

  def test_type_by_haenawa_label
    attrs = {
      command: 'type',
      target: %q|haenawaLabel=id-foo'bar"baz\quux#{hoge}hogehoge|,
      value: %q|value-foo'bar"baz\quux#{hoge}hogehoge|
    }
    step = create(:step, :for_build_history, attrs)
    partial = step.step_command.render

    assert_partial_string_without_indent(<<'EOS', partial)
first(:field, "id-foo'bar\"baz\\quux\#{hoge}hogehoge").set("value-foo'bar\"baz\\quux\#{hoge}hogehoge")
EOS
  end

  def test_type_password
    attrs = {
      command: 'type',
      target: %q|xpath=id-foo'bar"baz\quux#{hoge}hogehoge|,
      encrypted_value: %q|WG0vbWhLYTN4L21XUWZYV2NXT3VKQT09LS1PeHUvNVBrVUkrcjdOZDlvZVdJQUZRPT0=--c03a5e1332b82fa7f510911574c732f6a604ddea|
    }
    step = create(:step, :for_build_history, attrs)
    partial = step.step_command.render

    assert_partial_string_without_indent(<<'EOS', partial)
first(:xpath, "id-foo'bar\"baz\\quux\#{hoge}hogehoge").set("hello")
EOS
  end

  def test_attach_file_by_id
    File.stub(:exists?, true) do
      attrs = {
        command: 'type',
        target: 'id=upload',
        value: '//path/to/file'
      }
      step = create(:step, :for_build_history, attrs)
      partial = step.step_command.render

      assert_partial_string_without_indent(<<'EOS', partial)
first(:id, "upload").attach_file("//path/to/file")
EOS
    end
  end

  def test_attach_file_by_name
    File.stub(:exists?, true) do
      attrs = {
        command: 'type',
        target: 'name=upload',
        value: '//path/to/file'
      }
      step = create(:step, :for_build_history, attrs)
      partial = step.step_command.render

      assert_partial_string_without_indent(<<'EOS', partial)
first(:css, '[name="upload"]').attach_file("//path/to/file")
EOS
    end
  end

  def test_check_unsupported_target
    step = Step.new(step_no: 1, command: 'type', target: 'unsupported=example', value: 'example')
    partial = step.step_command.render

    assert_partial_string_without_indent(<<EOS, partial)
raise "サポートしていない対象エレメントです。| type | unsupported=example | example |"
EOS
  end

  def test_validate_target_allow_id_strategy
    step = Step.new(step_no: 1, command: 'type', target: 'id=example', value: 'example')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_target_allow_xpath_strategy
    step = Step.new(step_no: 1, command: 'type', target: 'xpath=//example', value: 'example')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_target_allow_xpath_short_strategy
    step = Step.new(step_no: 1, command: 'type', target: '//example', value: 'example')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_target_allow_css_strategy
    step = Step.new(step_no: 1, command: 'type', target: 'css=#example', value: 'example')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_target_allow_link_strategy
    step = Step.new(step_no: 1, command: 'type', target: 'link=http://example.com', value: 'example')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_target_allow_link_text_strategy
    step = Step.new(step_no: 1, command: 'type', target: 'linkText=example', value: 'example')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_target_allow_name_strategy
    step = Step.new(step_no: 1, command: 'type', target: 'name=example', value: 'example')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_target_allow_haenawa_label_strategy
    step = Step.new(step_no: 1, command: 'type', target: 'haenawaLabel=example', value: 'example')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_target_do_not_allow_invalid_strategy
    step = Step.new(step_no: 1, command: 'type', target: 'invalid=example', value: 'example')
    step.step_command.validate
    expected = %w(対象エレメントの指定は正しくありません。対象エレメントの指定例をご参考ください。)
    assert_equal(expected, step.errors.full_messages)
  end

  def test_validate_target_require_strategy_and_locator
    step = Step.new(step_no: 1, command: 'type', target: '=', value: 'example')
    step.step_command.validate
    expected = %w(対象エレメントの指定は正しくありません。対象エレメントの指定例をご参考ください。)
    assert_equal(expected, step.errors.full_messages)
  end

  def test_validate_target_require_strategy
    step = Step.new(step_no: 1, command: 'type', target: '=example', value: 'example')
    step.step_command.validate
    expected = %w(対象エレメントの指定は正しくありません。対象エレメントの指定例をご参考ください。)
    assert_equal(expected, step.errors.full_messages)
  end

  def test_validate_target_require_locator
    step = Step.new(step_no: 1, command: 'type', target: 'id=', value: 'example')
    step.step_command.validate
    expected = %w(対象エレメントの指定は正しくありません。対象エレメントの指定例をご参考ください。)
    assert_equal(expected, step.errors.full_messages)
  end

  def test_validate_target_do_not_allow_blank
    step = Step.new(step_no: 1, command: 'type', target: '', value: 'example')
    step.step_command.validate
    expected = %w(対象エレメントの指定は必須です。対象エレメントの指定例をご参考ください。)
    assert_equal(expected, step.errors.full_messages)
  end

  def test_validate_value_do_not_allow_blank
    step = Step.new(step_no: 1, command: 'type', target: 'id=example', value: '')
    step.step_command.validate
    expected = %w(値の指定は必須です。値の指定例をご参考ください。)
    assert_equal(expected, step.errors.full_messages)
  end

  def test_value_interpolation
    attrs = {
      command: 'type',
      target: 'id=example',
      value: '%{project_name} (%{project_id}), %{scenario_name} (%{scenario_id}), Build Number: %{build_history_id}, Device: %{build_history_device}'
    }
    step = create(:step, :for_build_history, attrs)
    partial = step.step_command.render
    build_history_id = step.steppable.id
    scenario_id = step.steppable.scenario.id
    project_id = step.steppable.scenario.project.id

    assert_partial_string_without_indent(<<"EOS", partial)
first(:id, "example").set("Test Project (#{project_id}), Test Scenario (#{scenario_id}), Build Number: #{build_history_id}, Device: ie")
EOS
  end

  def test_target_interpolation
    attrs = {
      command: 'type',
      target: 'name=project_%{project_id}_scenario_%{scenario_id}_build_%{build_history_id}_build_sequence_code_%{build_sequence_code}',
      value: 'example'
    }
    step = create(:step, :for_build_history, attrs)
    partial = step.step_command.render
    build_history_id = step.steppable.id
    scenario_id = step.steppable.scenario.id
    project_id = step.steppable.scenario.project.id
    build_sequence_code = step.steppable.build_sequence_code

    assert_partial_string_without_indent(<<"EOS", partial)
first(:css, '[name="project_#{project_id}_scenario_#{scenario_id}_build_#{build_history_id}_build_sequence_code_#{build_sequence_code}"]').set("example")
EOS
  end

  def test_validate_value_do_now_allow_invalid_placeholder
    attrs = {
      command: 'type',
      target: 'id=example',
      value: '%{invalid}'
    }
    step = create(:step, :for_v2_scenario, attrs)
    step.step_command.validate
    expected = %w(値のプレースホルダ指定は正しくありません。値の指定例をご参考ください。)
    assert_equal(expected, step.errors.full_messages)
  end

  def test_validate_target_do_now_allow_invalid_placeholder
    attrs = {
      command: 'type',
      target: 'id=%{invalid}',
      value: 'example'
    }
    step = create(:step, :for_v2_scenario, attrs)
    step.step_command.validate
    expected = %w(対象エレメントのプレースホルダ指定は正しくありません。対象エレメントの指定例をご参考ください。)
    assert_equal(expected, step.errors.full_messages)
  end
end
