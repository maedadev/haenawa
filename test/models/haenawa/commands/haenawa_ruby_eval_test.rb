require 'test_helper'

class HaenawaRubyEvalTest < ActiveSupport::TestCase
  def test_validate_target_allow_blank
    step = Step.new(step_no: 1, command: 'haenawaRubyEval', target: '', value: 'example')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_target_allow_any
    step = Step.new(step_no: 1, command: 'haenawaRubyEval', target: 'example', value: 'example')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_value_do_now_allow_invalid_placeholder
    attrs = {
      command: 'haenawaRubyEval',
      target: 'id=example',
      value: '%{invalid}'
    }
    step = create(:step, :for_v2_scenario, attrs)
    step.step_command.validate
    expected = %w(値のプレースホルダ指定は正しくありません。値の指定例をご参考ください。)
    assert_equal(expected, step.errors.full_messages)
  end

  def test_value_interpolation
    attrs = {
      command: 'haenawaRubyEval',
      target: 'id=example',
      value: 'find(:link, "Project%{project_id}BuildCode%{build_sequence_code}")'
    }
    step = create(:step, :for_build_history, attrs)
    project_id = step.steppable.scenario.project.id
    build_sequence_code = step.steppable.build_sequence_code
    partial = step.step_command.render
    assert_partial_string_without_indent(<<"EOS", partial)
find(:link, "Project#{project_id}BuildCode#{build_sequence_code}")
EOS
  end

  def test_validate_value_allow_script
    script =<<SCRIPT
class Greeter
   def initialize(name)
      @name = name.capitalize
   end
   def greet
      puts "Hello #{@name}!"
   end
end

greeter = Greeter.new("world")
greeter.greet
SCRIPT
    step = Step.new(step_no: 1, command: 'haenawaRubyEval', target: '', value: script)
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_value_do_not_allow_blank
    step = Step.new(step_no: 1, command: 'haenawaRubyEval', target: '', value: '')
    step.step_command.validate
    expected = %w(値の指定は必須です。値の指定例をご参考ください。)
    assert_equal(expected, step.errors.full_messages)
  end
end

